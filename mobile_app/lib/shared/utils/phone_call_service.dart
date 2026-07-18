/// PhoneCallService
///
/// A single place to launch phone calls and SMS from anywhere in the app.
/// Wraps url_launcher with a confirmation dialog for non-emergency numbers
/// and a direct dial for known emergency numbers (102, 100, 101, etc.).
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Well-known emergency numbers that get a direct call without a
/// "are you sure?" dialog — every second counts.
const _kDirectDialNumbers = {'100', '101', '102', '104', '108', '112', '1098', '1091'};

class PhoneCallService {
  PhoneCallService._();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Dials [number].
  ///
  /// * For recognised emergency numbers: places the call immediately via
  ///   `tel:` scheme (no confirmation needed).
  /// * For personal contacts / hospital numbers: shows a bottom-sheet
  ///   confirmation so the user doesn't accidentally call.
  ///
  /// [label] is shown in the confirmation sheet (e.g. contact name).
  static Future<void> call(
    BuildContext context,
    String number, {
    String? label,
  }) async {
    final clean = _clean(number);
    if (clean.isEmpty) return;

    if (_kDirectDialNumbers.contains(clean)) {
      await _dial(context, clean);
    } else {
      if (!context.mounted) return;
      final confirmed = await _showConfirmDialog(context, clean, label: label);
      if (confirmed == true && context.mounted) {
        await _dial(context, clean);
      }
    }
  }

  /// Opens the SMS composer for [number].
  static Future<void> sms(
    BuildContext context,
    String number, {
    String body = '',
  }) async {
    final clean = _clean(number);
    if (clean.isEmpty) return;

    final uri = Uri(
      scheme: 'sms',
      path: clean,
      queryParameters: body.isNotEmpty ? {'body': body} : null,
    );

    if (!await launchUrl(uri)) {
      if (context.mounted) _showError(context, 'Could not open SMS app.');
    }
  }

  /// Opens Google Maps (or the system maps app) to navigate to [address].
  /// Falls back to a geo: URI if maps: is unavailable.
  static Future<void> openMap(
    BuildContext context,
    String address,
  ) async {
    final encoded = Uri.encodeComponent(address);
    final googleMaps = Uri.parse('https://maps.google.com/?q=$encoded');
    final geoUri = Uri(scheme: 'geo', path: '0,0', queryParameters: {'q': address});

    if (await canLaunchUrl(googleMaps)) {
      await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      if (context.mounted) _showError(context, 'Could not open maps app.');
    }
  }

  // ── Internal helpers ───────────────────────────────────────────────────────

  static String _clean(String number) =>
      number.replaceAll(RegExp(r'[\s\-()]+'), '');

  static Future<void> _dial(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        _showError(context, 'Could not launch dialer for $number.');
      }
    }
  }

  static Future<bool?> _showConfirmDialog(
    BuildContext context,
    String number, {
    String? label,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CallConfirmSheet(number: number, label: label),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── Confirmation bottom sheet ─────────────────────────────────────────────────

class _CallConfirmSheet extends StatelessWidget {
  final String number;
  final String? label;

  const _CallConfirmSheet({required this.number, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('📞', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 14),
          if (label != null)
            Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 26,
              color: Color(0xFFDC2626),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Do you want to call this number?',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text(
                    'Call Now',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: const Color(0xFFDC2626),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
