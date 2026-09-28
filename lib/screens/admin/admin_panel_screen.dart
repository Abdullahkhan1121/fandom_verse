import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fandom_verse/screens/admin/admin_drawer.dart';
import 'package:fandom_verse/screens/admin/fandom_mng.dart';
import 'package:fandom_verse/screens/admin/mng_event.dart';
import 'package:fandom_verse/screens/admin/prd_mnd.dart';
import 'package:fandom_verse/screens/admin/user_mng.dart';
import 'package:fandom_verse/screens/admin/admin_inquiries_screen.dart';
import 'package:fandom_verse/services/inquiry_service.dart';
import 'package:fandom_verse/screens/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Admin dashboard: live KPIs, signup trend, fandom popularity, sales,
/// events, inventory health and recent activity.
///
/// Uses only [AppColors] / [AppTheme] (no extra packages needed). All charts
/// are drawn with CustomPaint. Everything updates in real time from Firestore.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _db = FirebaseFirestore.instance;
  final List<StreamSubscription<dynamic>> _subs = [];

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _users = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _fandoms = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _events = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _products = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _orders = [];

  bool _usersLoaded = false;
  bool _fandomsLoaded = false;
  bool _eventsLoaded = false;
  bool _productsLoaded = false;
  bool _ordersLoaded = false;
  bool _ordersError = false;

  final InquiryService _inquiryService = InquiryService();
  int _newInquiries = 0;
  StreamSubscription<int>? _inquirySub;

  int _signupDays = 7;

  @override
  void initState() {
    super.initState();

    _subs.add(_db
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .listen((s) {
      if (!mounted) return;
      setState(() {
        _users = s.docs;
        _usersLoaded = true;
      });
    }, onError: (_) {
      if (mounted) setState(() => _usersLoaded = true);
    }));

    _subs.add(_db.collection('fandoms').snapshots().listen((s) {
      if (!mounted) return;
      setState(() {
        _fandoms = s.docs;
        _fandomsLoaded = true;
      });
    }, onError: (_) {
      if (mounted) setState(() => _fandomsLoaded = true);
    }));

    _subs.add(_db.collection('events').snapshots().listen((s) {
      if (!mounted) return;
      setState(() {
        _events = s.docs;
        _eventsLoaded = true;
      });
    }, onError: (_) {
      if (mounted) setState(() => _eventsLoaded = true);
    }));

    _subs.add(_db.collection('products').snapshots().listen((s) {
      if (!mounted) return;
      setState(() {
        _products = s.docs;
        _productsLoaded = true;
      });
    }, onError: (_) {
      if (mounted) setState(() => _productsLoaded = true);
    }));

    _inquirySub = _inquiryService.watchNewCount().listen((count) {
      if (!mounted) return;
      setState(() => _newInquiries = count);
    });

    // Orders may be blocked by security rules for some setups, so a failure
    // here only hides the sales cards instead of breaking the dashboard.
    _subs.add(_db.collection('orders').snapshots().listen((s) {
      if (!mounted) return;
      setState(() {
        _orders = s.docs;
        _ordersLoaded = true;
        _ordersError = false;
      });
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _ordersLoaded = true;
          _ordersError = true;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _inquirySub?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------

  DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  String _str(Map<String, dynamic> d, String k, [String fallback = '']) {
    final v = d[k];
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _ago(DateTime? t) {
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day} ${_month(t.month)}';
  }

  String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  String _weekday(int d) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];

  String _money(double v, [String currency = 'USD']) {
    final symbol = currency == 'USD' ? '\$' : '$currency ';
    final whole = v.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final fromEnd = whole.length - i;
      buf.write(whole[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return '$symbol$buf';
  }

  String _compact(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(0)}k';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _go(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ------------------------------------------------------------------
  // Derived analytics
  // ------------------------------------------------------------------

  int get _newUsersThisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _users.where((u) {
      final t = _ts(u.data()['createdAt']);
      return t != null && t.isAfter(cutoff);
    }).length;
  }

  int get _activeUsers =>
      _users.where((u) => u.data()['active'] == true).length;

  List<double> _signupSeries(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<double>.filled(days, 0);
    for (final u in _users) {
      final t = _ts(u.data()['createdAt']);
      if (t == null) continue;
      final day = DateTime(t.year, t.month, t.day);
      final idx = days - 1 - today.difference(day).inDays;
      if (idx >= 0 && idx < days) counts[idx] += 1;
    }
    return counts;
  }

  /// fandomId -> number of users who favorited it.
  List<MapEntry<String, int>> get _topFollowedFandoms {
    final counts = <String, int>{};
    for (final u in _users) {
      final ids = u.data()['favoriteFandomIds'];
      if (ids is List) {
        for (final id in ids) {
          final key = id.toString();
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }
    }
    final names = {
      for (final f in _fandoms) f.id: _str(f.data(), 'name', 'Unnamed')
    };
    final list = counts.entries
        .where((e) => names.containsKey(e.key))
        .map((e) => MapEntry(names[e.key]!, e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list.take(5).toList();
  }

  int get _outOfStock =>
      _products.where((p) => ((p.data()['stock'] ?? 0) as num) <= 0).length;

  int get _lowStock => _products.where((p) {
        final s = ((p.data()['stock'] ?? 0) as num);
        return s > 0 && s <= 5;
      }).length;

  int get _hiddenProducts => _products.where((p) {
        final d = p.data();
        final s = ((d['stock'] ?? 0) as num);
        return d['isAvailable'] != true && s > 0;
      }).length;

  int get _healthyProducts {
    final v = _products.length - _outOfStock - _hiddenProducts;
    return v < 0 ? 0 : v;
  }

  double get _inventoryValue {
    double total = 0;
    for (final p in _products) {
      final d = p.data();
      total += ((d['price'] ?? 0) as num).toDouble() *
          ((d['stock'] ?? 0) as num).toDouble();
    }
    return total;
  }

  bool _isCancelled(String status) {
    final s = status.toLowerCase();
    return s == 'cancelled' || s == 'canceled' || s == 'refunded';
  }

  double get _revenue {
    double total = 0;
    for (final o in _orders) {
      final d = o.data();
      if (_isCancelled(_str(d, 'status', 'pending'))) continue;
      total += ((d['totalAmount'] ?? 0) as num).toDouble();
    }
    return total;
  }

  String get _currency {
    for (final o in _orders) {
      final c = _str(o.data(), 'currency');
      if (c.isNotEmpty) return c;
    }
    for (final p in _products) {
      final c = _str(p.data(), 'currency');
      if (c.isNotEmpty) return c;
    }
    return 'USD';
  }

  Map<String, int> get _orderStatusCounts {
    final map = <String, int>{};
    for (final o in _orders) {
      final s = _str(o.data(), 'status', 'pending').toLowerCase();
      map[s] = (map[s] ?? 0) + 1;
    }
    return map;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return AppColors.success;
      case 'shipped':
      case 'processing':
      case 'confirmed':
        return AppColors.accent;
      case 'cancelled':
      case 'canceled':
      case 'refunded':
        return AppColors.danger;
      default:
        return AppColors.gold;
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  // Event buckets
  int get _upcomingEvents => _events.where((e) {
        final d = e.data();
        final start = _ts(d['startAt']);
        return d['isPublished'] == true &&
            start != null &&
            start.isAfter(DateTime.now());
      }).length;

  int get _liveEvents => _events.where((e) {
        final d = e.data();
        final start = _ts(d['startAt']);
        final end = _ts(d['endAt']);
        final now = DateTime.now();
        return d['isPublished'] == true &&
            start != null &&
            end != null &&
            !start.isAfter(now) &&
            !end.isBefore(now);
      }).length;

  int get _pastEvents => _events.where((e) {
        final end = _ts(e.data()['endAt']);
        return end != null && end.isBefore(DateTime.now());
      }).length;

  int get _draftEvents =>
      _events.where((e) => e.data()['isPublished'] != true).length;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _nextEvents {
    final now = DateTime.now();
    final list = _events.where((e) {
      final d = e.data();
      final end = _ts(d['endAt']) ?? _ts(d['startAt']);
      return d['isPublished'] == true && end != null && end.isAfter(now);
    }).toList()
      ..sort((a, b) {
        final at = _ts(a.data()['startAt']) ?? DateTime(2100);
        final bt = _ts(b.data()['startAt']) ?? DateTime(2100);
        return at.compareTo(bt);
      });
    return list.take(3).toList();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _lowStockProducts {
    final list = _products.where((p) {
      final s = ((p.data()['stock'] ?? 0) as num);
      return s <= 5;
    }).toList()
      ..sort((a, b) => ((a.data()['stock'] ?? 0) as num)
          .compareTo((b.data()['stock'] ?? 0) as num));
    return list.take(4).toList();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _recentUsers {
    final list = [..._users]..sort((a, b) {
        final at = _ts(a.data()['createdAt']);
        final bt = _ts(b.data()['createdAt']);
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
    return list.take(5).toList();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _recentOrders {
    final list = [..._orders]..sort((a, b) {
        final at = _ts(a.data()['createdAt']);
        final bt = _ts(b.data()['createdAt']);
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
    return list.take(4).toList();
  }

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: _livePill()),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final wide = width >= 860;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hero(),
                      const SizedBox(height: 22),
                      _kpiGrid(width - 40),
                      const SizedBox(height: 26),
                      _sectionTitle('Quick actions'),
                      const SizedBox(height: 12),
                      _quickActions(),
                      const SizedBox(height: 26),
                      _sectionTitle('Audience'),
                      const SizedBox(height: 12),
                      _twoCol(wide, _signupsCard(), _followedCard()),
                      const SizedBox(height: 26),
                      _sectionTitle('Store & sales'),
                      const SizedBox(height: 12),
                      _twoCol(wide, _salesCard(), _inventoryCard()),
                      const SizedBox(height: 26),
                      _sectionTitle('Events'),
                      const SizedBox(height: 12),
                      _eventsCard(),
                      const SizedBox(height: 26),
                      _sectionTitle('Recent activity'),
                      const SizedBox(height: 12),
                      _twoCol(wide, _recentUsersCard(), _recentOrdersCard()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _twoCol(bool wide, Widget a, Widget b) {
    if (!wide) {
      return Column(children: [a, const SizedBox(height: 16), b]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );
  }

  Widget _livePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: AppColors.success),
          SizedBox(width: 6),
          Text(
            'Live',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Hero
  // ------------------------------------------------------------------

  Widget _hero() {
    final user = FirebaseAuth.instance.currentUser;
    var name = (user?.displayName ?? '').trim();
    if (name.isEmpty) {
      final email = (user?.email ?? '').trim();
      name = email.contains('@') ? email.split('@').first : 'Admin';
    }
    final now = DateTime.now();
    final date = '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)}';

    final attention = _outOfStock +
        (_ordersError
            ? 0
            : _orders
                .where((o) =>
                    _str(o.data(), 'status', 'pending').toLowerCase() ==
                    'pending')
                .length);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDeep.withValues(alpha: 0.55),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primaryLight.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_greeting()}, $name',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  attention > 0
                      ? '$attention item${attention == 1 ? '' : 's'} need your attention today.'
                      : 'Everything is running smoothly on Fandom Verse.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // KPI cards
  // ------------------------------------------------------------------

  Widget _kpiGrid(double width) {
    final cols = width < 560 ? 2 : (width < 900 ? 3 : 6);
    const gap = 12.0;
    final itemWidth = (width - gap * (cols - 1)) / cols;

    final newWeek = _newUsersThisWeek;
    final orderCount = _orders.length;

    final cards = <Widget>[
      _KpiCard(
        icon: Icons.people_alt_rounded,
        color: AppColors.accent,
        label: 'Users',
        value: _usersLoaded ? _users.length.toDouble() : null,
        footnote: _usersLoaded
            ? (newWeek > 0 ? '+$newWeek this week' : '$_activeUsers active')
            : '',
        footnoteColor: newWeek > 0 ? AppColors.success : AppColors.textMuted,
      ),
      _KpiCard(
        icon: Icons.auto_awesome_rounded,
        color: AppColors.primaryLight,
        label: 'Fandoms',
        value: _fandomsLoaded ? _fandoms.length.toDouble() : null,
        footnote: _fandomsLoaded
            ? '${_fandoms.where((f) => f.data()['isTrending'] == true).length} trending'
            : '',
      ),
      _KpiCard(
        icon: Icons.event_rounded,
        color: AppColors.gold,
        label: 'Events',
        value: _eventsLoaded ? _events.length.toDouble() : null,
        footnote: _eventsLoaded ? '$_upcomingEvents upcoming' : '',
      ),
      _KpiCard(
        icon: Icons.shopping_bag_rounded,
        color: AppColors.success,
        label: 'Products',
        value: _productsLoaded ? _products.length.toDouble() : null,
        footnote: _productsLoaded
            ? (_outOfStock > 0 ? '$_outOfStock out of stock' : 'All in stock')
            : '',
        footnoteColor:
            _outOfStock > 0 ? AppColors.danger : AppColors.textMuted,
      ),
      _KpiCard(
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFB58CFF),
        label: 'Orders',
        value: _ordersLoaded && !_ordersError ? orderCount.toDouble() : null,
        unavailable: _ordersError,
        footnote: _ordersLoaded && !_ordersError
            ? '${_orderStatusCounts['pending'] ?? 0} pending'
            : '',
      ),
      _KpiCard(
        icon: Icons.payments_rounded,
        color: const Color(0xFF4FD1C5),
        label: 'Revenue',
        value: _ordersLoaded && !_ordersError ? _revenue : null,
        unavailable: _ordersError,
        formatter: (v) => _money(v, _currency),
        footnote: _ordersLoaded && !_ordersError && orderCount > 0
            ? 'Avg ${_money(_revenue / orderCount, _currency)} / order'
            : '',
      ),
    ];

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: cards
          .map((c) => SizedBox(width: itemWidth, height: 128, child: c))
          .toList(),
    );
  }

  // ------------------------------------------------------------------
  // Quick actions
  // ------------------------------------------------------------------

  Widget _quickActions() {
    final actions = <_ActionData>[
      _ActionData('Fandoms', Icons.auto_awesome_rounded,
          AppColors.primaryLight, () => _go(const FandomManagementScreen())),
      _ActionData('Events', Icons.event_rounded, AppColors.gold,
          () => _go(const ManageEventsScreen())),
      _ActionData('Products', Icons.shopping_bag_rounded, AppColors.success,
          () => _go(const ProductManagementScreen())),
      _ActionData('Users', Icons.people_alt_rounded, AppColors.accent,
          () => _go(const UserManagementScreen())),
      _ActionData('Inquiries', Icons.mail_rounded, AppColors.danger,
          () => _go(const AdminInquiriesScreen()),
          badgeCount: _newInquiries),
    ];

    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth < 520 ? 2 : 4;
      const gap = 12.0;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: actions
            .map((a) => SizedBox(width: w, child: _ActionTile(data: a)))
            .toList(),
      );
    });
  }

  // ------------------------------------------------------------------
  // Audience
  // ------------------------------------------------------------------

  Widget _signupsCard() {
    final series = _signupSeries(_signupDays);
    final total = series.fold<double>(0, (a, b) => a + b).toInt();
    final now = DateTime.now();
    final first = now.subtract(Duration(days: _signupDays - 1));
    final labels = [
      '${first.day} ${_month(first.month)}',
      '${now.day} ${_month(now.month)}',
    ];

    return _Panel(
      title: 'New signups',
      subtitle: '$total in the last $_signupDays days',
      trailing: _segmented(),
      child: !_usersLoaded
          ? const _Loading(height: 190)
          : (total == 0 && _users.isEmpty)
              ? const _Empty(
                  icon: Icons.show_chart_rounded,
                  text: 'No users yet. Signups will chart here.')
              : Column(
                  children: [
                    SizedBox(
                      height: 170,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _LineChartPainter(
                          values: series,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(labels.first, style: _axisStyle),
                        Text(labels.last, style: _axisStyle),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _MiniStat(
                            label: 'Total',
                            value: '${_users.length}',
                            color: AppColors.accent),
                        _MiniStat(
                            label: 'Active',
                            value: '$_activeUsers',
                            color: AppColors.success),
                        _MiniStat(
                            label: 'Unverified',
                            value:
                                '${_users.where((u) => u.data()['emailVerified'] != true).length}',
                            color: AppColors.gold),
                      ],
                    ),
                  ],
                ),
    );
  }

  static const TextStyle _axisStyle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  Widget _segmented() {
    Widget item(int days) {
      final selected = _signupDays == days;
      return GestureDetector(
        onTap: () => setState(() => _signupDays = days),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '${days}D',
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        item(7),
        item(30),
      ]),
    );
  }

  Widget _followedCard() {
    final top = _topFollowedFandoms;
    final maxV = top.isEmpty ? 1 : top.first.value;
    final colors = [
      AppColors.primaryLight,
      AppColors.accent,
      AppColors.gold,
      AppColors.success,
      const Color(0xFFB58CFF),
    ];

    return _Panel(
      title: 'Most followed fandoms',
      subtitle: 'Based on users\u2019 favorites',
      child: !(_usersLoaded && _fandomsLoaded)
          ? const _Loading(height: 190)
          : top.isEmpty
              ? const _Empty(
                  icon: Icons.favorite_border_rounded,
                  text: 'No favorites yet. Popular fandoms appear here.')
              : Column(
                  children: [
                    for (var i = 0; i < top.length; i++)
                      _BarRow(
                        rank: i + 1,
                        label: top[i].key,
                        valueText: '${top[i].value}',
                        fraction: top[i].value / maxV,
                        color: colors[i % colors.length],
                      ),
                  ],
                ),
    );
  }

  // ------------------------------------------------------------------
  // Store & sales
  // ------------------------------------------------------------------

  Widget _salesCard() {
    final counts = _orderStatusCounts;
    final total = _orders.length;

    Widget body;
    if (_ordersError) {
      body = const _Empty(
          icon: Icons.lock_outline_rounded,
          text:
              'Orders are not readable with the current Firestore rules. Allow admins to read the orders collection to see sales.');
    } else if (!_ordersLoaded) {
      body = const _Loading(height: 160);
    } else if (total == 0) {
      body = const _Empty(
          icon: Icons.receipt_long_rounded,
          text: 'No orders yet. Sales analytics will show up here.');
    } else {
      final entries = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(_revenue, _currency),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('total revenue', style: _axisStyle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  for (final e in entries)
                    Expanded(
                      flex: e.value,
                      child: Container(color: _statusColor(e.key)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final e in entries)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _statusColor(e.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_cap(e.key)} \u00B7 ${e.value}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      );
    }

    return _Panel(
      title: 'Sales overview',
      subtitle: _ordersError ? 'Unavailable' : '$total orders placed',
      child: body,
    );
  }

  Widget _inventoryCard() {
    final segments = <_Segment>[
      _Segment('Healthy', _healthyProducts.toDouble(), AppColors.success),
      _Segment('Hidden', _hiddenProducts.toDouble(), AppColors.gold),
      _Segment('Out of stock', _outOfStock.toDouble(), AppColors.danger),
    ];
    final low = _lowStockProducts;

    return _Panel(
      title: 'Inventory health',
      subtitle: _productsLoaded
          ? 'Stock value ${_money(_inventoryValue, _currency)}'
          : '',
      child: !_productsLoaded
          ? const _Loading(height: 190)
          : _products.isEmpty
              ? const _Empty(
                  icon: Icons.inventory_2_outlined,
                  text: 'No products yet. Add products to track stock.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 118,
                          height: 118,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(118, 118),
                                painter: _DonutPainter(segments: segments),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_products.length}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Text('products', style: _axisStyle),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            children: [
                              for (final s in segments)
                                _LegendRow(
                                    color: s.color,
                                    label: s.label,
                                    value: s.value.toInt()),
                              _LegendRow(
                                  color: AppColors.accent,
                                  label: 'Low stock (\u22645)',
                                  value: _lowStock),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (low.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text(
                        'NEEDS RESTOCKING',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final p in low)
                        _StockRow(
                          name: _str(p.data(), 'name', 'Unnamed product'),
                          stock: ((p.data()['stock'] ?? 0) as num).toInt(),
                        ),
                    ],
                  ],
                ),
    );
  }

  // ------------------------------------------------------------------
  // Events
  // ------------------------------------------------------------------

  Widget _eventsCard() {
    final next = _nextEvents;
    final fandomNames = {
      for (final f in _fandoms) f.id: _str(f.data(), 'name', '')
    };

    return _Panel(
      title: 'Events snapshot',
      subtitle: _eventsLoaded ? '${_events.length} total events' : '',
      child: !_eventsLoaded
          ? const _Loading(height: 140)
          : _events.isEmpty
              ? const _Empty(
                  icon: Icons.event_busy_rounded,
                  text: 'No events yet. Create one from Manage Events.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _MiniStat(
                            label: 'Live now',
                            value: '$_liveEvents',
                            color: AppColors.success),
                        _MiniStat(
                            label: 'Upcoming',
                            value: '$_upcomingEvents',
                            color: AppColors.gold),
                        _MiniStat(
                            label: 'Past',
                            value: '$_pastEvents',
                            color: AppColors.textMuted),
                        _MiniStat(
                            label: 'Drafts',
                            value: '$_draftEvents',
                            color: AppColors.accent),
                      ],
                    ),
                    if (next.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      for (final e in next)
                        _EventRow(
                          title: _str(e.data(), 'title', 'Untitled event'),
                          start: _ts(e.data()['startAt']),
                          place: [
                            _str(e.data(), 'city'),
                            fandomNames[_str(e.data(), 'fandomId')] ?? '',
                          ].where((s) => s.isNotEmpty).join(' \u00B7 '),
                          month: _month,
                        ),
                    ],
                  ],
                ),
    );
  }

  // ------------------------------------------------------------------
  // Recent activity
  // ------------------------------------------------------------------

  Widget _recentUsersCard() {
    final list = _recentUsers;
    return _Panel(
      title: 'Newest members',
      subtitle: 'Latest registrations',
      trailing: _linkButton('View all', () => _go(const UserManagementScreen())),
      child: !_usersLoaded
          ? const _Loading(height: 140)
          : list.isEmpty
              ? const _Empty(
                  icon: Icons.person_outline_rounded,
                  text: 'No members yet.')
              : Column(
                  children: [
                    for (final u in list)
                      _PersonRow(
                        name: _str(
                            u.data(),
                            'name',
                            _str(u.data(), 'displayName', 'Unknown user')),
                        email: _str(u.data(), 'email'),
                        when: _ago(_ts(u.data()['createdAt'])),
                        verified: u.data()['emailVerified'] == true,
                      ),
                  ],
                ),
    );
  }

  Widget _recentOrdersCard() {
    final list = _recentOrders;

    Widget body;
    if (_ordersError) {
      body = const _Empty(
          icon: Icons.lock_outline_rounded,
          text: 'Orders are not available with the current permissions.');
    } else if (!_ordersLoaded) {
      body = const _Loading(height: 140);
    } else if (list.isEmpty) {
      body = const _Empty(
          icon: Icons.receipt_long_rounded, text: 'No orders yet.');
    } else {
      body = Column(
        children: [
          for (final o in list)
            _OrderRow(
              code: o.id.length > 6
                  ? o.id.substring(o.id.length - 6).toUpperCase()
                  : o.id.toUpperCase(),
              items: (o.data()['items'] is List)
                  ? (o.data()['items'] as List).length
                  : 0,
              total: _money(((o.data()['totalAmount'] ?? 0) as num).toDouble(),
                  _str(o.data(), 'currency', 'USD')),
              status: _cap(_str(o.data(), 'status', 'pending')),
              statusColor: _statusColor(_str(o.data(), 'status', 'pending')),
              when: _ago(_ts(o.data()['createdAt'])),
            ),
        ],
      );
    }

    return _Panel(
      title: 'Latest orders',
      subtitle: 'Most recent purchases',
      child: body,
    );
  }

  Widget _linkButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// Reusable building blocks
// ======================================================================

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.subtitle = '',
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.footnote = '',
    this.footnoteColor = AppColors.textMuted,
    this.formatter,
    this.unavailable = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final double? value;
  final String footnote;
  final Color footnoteColor;
  final String Function(double)? formatter;
  final bool unavailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          if (unavailable)
            const Text('\u2014',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 24,
                    fontWeight: FontWeight.w800))
          else if (value == null)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value!),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatter != null ? formatter!(v) : v.round().toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 3),
          Text(
            footnote.isEmpty ? ' ' : footnote,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: footnoteColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  _ActionData(this.label, this.icon, this.color, this.onTap,
      {this.badgeCount = 0});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.data});
  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Manage ${data.label}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              if (data.badgeCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.badgeCount > 99 ? '99+' : '${data.badgeCount}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textMuted, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.rank,
    required this.label,
    required this.valueText,
    required this.fraction,
    required this.color,
  });

  final int rank;
  final String label;
  final String valueText;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$rank',
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                valueText,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction.clamp(0.04, 1.0)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: AppColors.surfaceHigh,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow(
      {required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  const _StockRow({required this.name, required this.stock});
  final String name;
  final int stock;

  @override
  Widget build(BuildContext context) {
    final out = stock <= 0;
    final color = out ? AppColors.danger : AppColors.gold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              out ? 'Out of stock' : '$stock left',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.title,
    required this.start,
    required this.place,
    required this.month,
  });

  final String title;
  final DateTime? start;
  final String place;
  final String Function(int) month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              children: [
                Text(
                  start == null ? '--' : '${start!.day}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                Text(
                  start == null ? '' : month(start!.month).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.name,
    required this.email,
    required this.when,
    required this.verified,
  });

  final String name;
  final String email;
  final String when;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                verified
                    ? Icons.verified_rounded
                    : Icons.hourglass_bottom_rounded,
                size: 16,
                color: verified ? AppColors.success : AppColors.gold,
              ),
              if (when.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(when, style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                )),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.code,
    required this.items,
    required this.total,
    required this.status,
    required this.statusColor,
    required this.when,
  });

  final String code;
  final int items;
  final String total;
  final String status;
  final Color statusColor;
  final String when;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                color: statusColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$code',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$items item${items == 1 ? '' : 's'}${when.isEmpty ? '' : ' \u00B7 $when'}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 30),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// Chart painters
// ======================================================================

class _Segment {
  _Segment(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});
  final List<_Segment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    final total = segments.fold<double>(0, (a, b) => a + b.value);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.surfaceHigh;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (total <= 0) return;

    var start = -math.pi / 2;
    final nonZero = segments.where((s) => s.value > 0).length;
    final gap = nonZero > 1 ? 0.07 : 0.0;

    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = (s.value / total) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = s.color;
      final drawSweep = math.max(sweep - gap, 0.02);
      canvas.drawArc(rect, start + gap / 2, drawSweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.segments != segments;
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxRaw = values.reduce(math.max);
    final maxV = math.max(maxRaw, 3.0);
    const topPad = 10.0;
    const bottomPad = 6.0;
    final h = size.height - topPad - bottomPad;

    // Grid lines + y labels
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = topPad + h * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final n = values.length;
    final dx = n == 1 ? 0.0 : size.width / (n - 1);
    final points = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(
          n == 1 ? size.width / 2 : dx * i,
          topPad + h - (values[i] / maxV) * h,
        ),
    ];

    // Smooth path
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Fill
    final fill = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.32),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // Dots (only when few points) + last point highlight
    if (n <= 8) {
      for (final p in points) {
        canvas.drawCircle(p, 3.6, Paint()..color = AppColors.surface);
        canvas.drawCircle(
          p,
          3.6,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color,
        );
      }
    }
    final last = points.last;
    canvas.drawCircle(
        last, 9, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawCircle(last, 4.6, Paint()..color = color);

    // Peak label
    if (maxRaw > 0) {
      final peakIdx = values.indexOf(maxRaw);
      final tp = TextPainter(
        text: TextSpan(
          text: '${maxRaw.toInt()}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = points[peakIdx];
      final x = (p.dx - tp.width / 2).clamp(0.0, size.width - tp.width);
      final y = math.max(p.dy - tp.height - 8, 0.0);
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.values != values || old.color != color;
}