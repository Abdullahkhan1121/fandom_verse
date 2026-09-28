import 'package:flutter/material.dart';

import '../models/bookmark_model.dart';
import '../services/bookmark_service.dart';

/// A bookmark icon that works for any [BookmarkModel] (event, resource,
/// gallery image, ...). It shows filled when the item is saved and toggles
/// the bookmark when tapped.
///
/// Set [overlay] to true when it sits on top of an image.
class BookmarkButton extends StatefulWidget {
  const BookmarkButton({
    super.key,
    required this.bookmark,
    this.overlay = false,
  });

  final BookmarkModel bookmark;
  final bool overlay;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  final BookmarkService _service = BookmarkService();

  late final Stream<Set<String>> _keys = _service.watchKeys();

  Future<void> _toggle(bool currentlyOn) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _service.setBookmarked(widget.bookmark, on: !currentlyOn);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              currentlyOn ? 'Bookmark removed' : 'Saved for offline access',
            ),
          ),
        );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update bookmark: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Set<String>>(
      stream: _keys,
      initialData: const <String>{},
      builder: (context, snapshot) {
        final isSaved = (snapshot.data ?? const <String>{}).contains(
          widget.bookmark.key,
        );

        final button = IconButton(
          tooltip: isSaved ? 'Remove bookmark' : 'Bookmark',
          visualDensity: widget.overlay ? VisualDensity.compact : null,
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved
                ? Colors.amberAccent
                : (widget.overlay ? Colors.white : null),
          ),
          onPressed: () => _toggle(isSaved),
        );

        if (!widget.overlay) return button;

        return Container(
          margin: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: button,
        );
      },
    );
  }
}
