import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/fandom_image.dart';
import '../../models/bookmark_model.dart';
import '../../widgets/bookmark_button.dart';

// ============================================================
// MODEL
// Reads the same documents the admin "Add Event" screen writes.
// `city` and `ticketLink` are optional (older events won't have them).
// ============================================================

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.city,
    required this.ticketLink,
    required this.startAt,
    required this.endAt,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String location;
  final String city;
  final String ticketLink;
  final DateTime startAt;
  final DateTime endAt;

  bool get isUpcoming => endAt.isAfter(DateTime.now());

  factory EventModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    DateTime toDate(dynamic value) =>
        value is Timestamp ? value.toDate() : DateTime.now();

    final location = (data['location'] ?? '').toString().trim();

    // Use the `city` field if the admin filled it in. Otherwise guess it
    // from the last part of the location, e.g. "Expo Center, Karachi".
    String city = (data['city'] ?? '').toString().trim();
    if (city.isEmpty) {
      city = location.contains(',') ? location.split(',').last.trim() : location;
    }

    return EventModel(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      location: location,
      city: city,
      ticketLink: (data['ticketLink'] ?? '').toString().trim(),
      startAt: toDate(data['startAt']),
      endAt: toDate(data['endAt']),
    );
  }
}

// ============================================================
// EVENTS LIST SCREEN
// ============================================================

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // Only published events. Sorting/filtering is done in Dart so we
  // don't need a Firestore composite index.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      FirebaseFirestore.instance
          .collection('events')
          .where('isPublished', isEqualTo: true)
          .snapshots();

  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String _selectedCity = 'All';
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _applyFilters(List<EventModel> all) {
    final query = _search.toLowerCase();

    final filtered = all.where((e) {
      if (_showPast ? e.isUpcoming : !e.isUpcoming) return false;
      if (_selectedCity != 'All' && e.city != _selectedCity) return false;
      if (query.isEmpty) return true;
      return e.title.toLowerCase().contains(query) ||
          e.category.toLowerCase().contains(query) ||
          e.location.toLowerCase().contains(query);
    }).toList();

    filtered.sort(
      (a, b) => _showPast
          ? b.startAt.compareTo(a.startAt) // newest past event first
          : a.startAt.compareTo(b.startAt), // soonest upcoming first
    );
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load events.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final all =
              snapshot.data!.docs.map(EventModel.fromFirestore).toList();

          // Build the city chips from the events that actually exist.
          final cities = <String>{
            for (final e in all)
              if (e.city.isNotEmpty) e.city,
          }.toList()
            ..sort();

          // If the selected city disappeared (event deleted), reset it.
          final activeCity =
              (_selectedCity == 'All' || cities.contains(_selectedCity))
                  ? _selectedCity
                  : 'All';

          final events = _applyFilters(all);

          return Column(
            children: [
              // ---------- SEARCH ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _search = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search events, categories, places',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _search = '');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    isDense: true,
                  ),
                ),
              ),

              // ---------- CITY FILTER + PAST TOGGLE ----------
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final city in ['All', ...cities])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(city),
                          selected: activeCity == city,
                          onSelected: (_) =>
                              setState(() => _selectedCity = city),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        avatar: const Icon(Icons.history, size: 18),
                        label: const Text('Past events'),
                        selected: _showPast,
                        onSelected: (v) => setState(() => _showPast = v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // ---------- LIST (grouped by month) ----------
              Expanded(
                child: events.isEmpty
                    ? _EmptyEvents(showPast: _showPast)
                    : _buildGroupedList(events),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupedList(List<EventModel> events) {
    // Flatten into: month header, event, event, month header, event ...
    final items = <Object>[];
    String? lastMonth;
    for (final e in events) {
      final month = DateFormat('MMMM yyyy').format(e.startAt);
      if (month != lastMonth) {
        items.add(month);
        lastMonth = month;
      }
      items.add(e);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is String) {
          return Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              item,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          );
        }

        return _EventCard(event: item as EventModel);
      },
    );
  }
}

// ============================================================
// EVENT CARD
// ============================================================

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('d').format(event.startAt),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(event.startAt).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Title / place / category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(event.startAt),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                    if (event.category.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(event.category),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FandomImage(
                  imageUrl: event.imageUrl,
                  width: 72,
                  height: 72,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents({required this.showPast});

  final bool showPast;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 56, color: Colors.white54),
            const SizedBox(height: 12),
            Text(
              showPast ? 'No past events found' : 'No upcoming events found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Try a different search or city.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EVENT DETAIL SCREEN
// ============================================================

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final EventModel event;

  Future<void> _open(BuildContext context, Uri uri) async {
    bool opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  Uri _ticketUri() {
    final link = event.ticketLink;
    return Uri.parse(link.startsWith('http') ? link : 'https://$link');
  }

  BookmarkModel _bookmark() => BookmarkModel.event(
        id: event.id,
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        category: event.category,
        location: event.location,
        city: event.city,
        ticketLink: event.ticketLink,
        startAt: event.startAt,
        endAt: event.endAt,
      );

  Uri _mapUri() {
    // Opens Google Maps (app or browser) searching for the venue text.
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': event.location,
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('EEE, d MMM yyyy');
    final timeFmt = DateFormat('h:mm a');
    final sameDay = DateUtils.isSameDay(event.startAt, event.endAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [BookmarkButton(bookmark: _bookmark())],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FandomImage(
              imageUrl: event.imageUrl,
              height: 220,
              width: double.infinity,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            event.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: [
              if (event.category.isNotEmpty) Chip(label: Text(event.category)),
              Chip(
                label: Text(event.isUpcoming ? 'Upcoming' : 'Ended'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.calendar_today,
            text: sameDay
                ? '${dateFmt.format(event.startAt)}\n'
                    '${timeFmt.format(event.startAt)} - ${timeFmt.format(event.endAt)}'
                : 'Starts: ${dateFmt.format(event.startAt)}, ${timeFmt.format(event.startAt)}\n'
                    'Ends: ${dateFmt.format(event.endAt)}, ${timeFmt.format(event.endAt)}',
          ),

          _InfoRow(icon: Icons.place, text: event.location),

          const SizedBox(height: 16),

          if (event.description.isNotEmpty)
            Text(
              event.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),

          const SizedBox(height: 24),

          if (event.location.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () => _open(context, _mapUri()),
              icon: const Icon(Icons.map),
              label: const Text('View on Map'),
            ),

          if (event.ticketLink.isNotEmpty) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _open(context, _ticketUri()),
              icon: const Icon(Icons.confirmation_number),
              label: const Text('Get Tickets'),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}