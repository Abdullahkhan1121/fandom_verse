import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/app_info.dart';
import '../screens/theme/app_theme.dart';

/// Embedded Google Map for one [OfficeLocation], with a marker.
///
/// Falls back to a plain address card instead of a blank/broken map when:
///  * the device has no internet connection (checked before the map widget
///    is ever built, so the native map plugin is never asked to load), or
///  * the map does not report itself ready within [_readyTimeout] (covers a
///    missing/invalid API key on most devices).
///
/// This is a best-effort check, not a guarantee: Dart code cannot always
/// detect a bad Google Maps API key, because the native side fails quietly.
/// The device offline case is the one this reliably catches.
class OfficeMapCard extends StatefulWidget {
  const OfficeMapCard({super.key, required this.office});

  final OfficeLocation office;

  @override
  State<OfficeMapCard> createState() => _OfficeMapCardState();
}

enum _MapState { checking, available, unavailable }

class _OfficeMapCardState extends State<OfficeMapCard> {
  static const Duration _lookupTimeout = Duration(seconds: 4);
  static const Duration _readyTimeout = Duration(seconds: 6);

  _MapState _state = _MapState.checking;
  Timer? _readyTimer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _readyTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('maps.googleapis.com')
          .timeout(_lookupTimeout);
      final online = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      if (!mounted) return;
      setState(() => _state = online ? _MapState.available : _MapState.unavailable);
      if (online) _armReadyTimeout();
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _MapState.unavailable);
    }
  }

  /// If the map hasn't confirmed it's ready by the time this fires, assume
  /// something is wrong (bad key, blocked tiles, ...) and show the fallback.
  void _armReadyTimeout() {
    _readyTimer?.cancel();
    _readyTimer = Timer(_readyTimeout, () {
      if (!mounted || _state != _MapState.available) return;
      // Map never confirmed onMapCreated; fall back.
      setState(() => _state = _MapState.unavailable);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _readyTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final office = widget.office;
    final position = LatLng(office.latitude, office.longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: switch (_state) {
          _MapState.checking => const ColoredBox(
              color: AppColors.surfaceHigh,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          _MapState.unavailable => _FallbackCard(office: office),
          _MapState.available => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: position,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(office.name),
                  position: position,
                  infoWindow: InfoWindow(title: office.name),
                ),
              },
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              liteModeEnabled: true,
            ),
        },
      ),
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({required this.office});

  final OfficeLocation office;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceHigh,
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map_outlined, color: AppColors.textMuted, size: 28),
          const SizedBox(height: 8),
          Text(
            office.address,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
