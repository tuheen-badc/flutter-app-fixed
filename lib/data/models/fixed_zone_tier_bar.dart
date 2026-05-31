// fixed_zone_tier_bar.dart
//
// A 3-zone tier progress bar where each color zone always occupies a fixed
// visual proportion of the bar, so no zone ever collapses to a sliver
// regardless of the actual litre values.
//
//   Green  (Tier 1) → 35% of bar width
//   Yellow (Tier 2) → 20% of bar width
//   Red    (Tier 3) → 45% of bar width
//
// The downward-arrow indicator is positioned *within* the active zone based
// on how far through that zone the user currently is.

import 'package:flutter/material.dart';

class FixedZoneTierBar extends StatelessWidget {
  final double tierUsed;
  final double baseTierLimit; // end of green zone (Tier 1 → Tier 2 boundary)
  final double tierTwoLimit; // end of yellow zone (Tier 2 → Tier 3 boundary)
  final Color tierColor; // matches the user's current tier color

  /// When true, shows a small pulsing "updating live" label.
  final bool isLive;

  // Fixed visual proportions — change these to restyle both screens at once.
  static const double _greenEnd = 0.35; // 0.00 → 0.35
  static const double _yellowEnd = 0.55; // 0.35 → 0.55
  // red zone: 0.55 → 1.00 (0.45 wide)

  static const _success = Color(0xFF10B981);
  static const _warning = Color(0xFFF59E0B);
  static const _danger = Color(0xFFEF4444);
  static const _textSecondary = Color(0xFF718096);
  static const _textPrimary = Color(0xFF2D3748);

  const FixedZoneTierBar({
    Key? key,
    required this.tierUsed,
    required this.baseTierLimit,
    required this.tierTwoLimit,
    required this.tierColor,
    this.isLive = false,
  }) : super(key: key);

  // ── Arrow position (0.0 – 1.0 fraction of bar width) ─────────────────────
  //
  // Each zone maps its own [0, 1] progress onto its fixed visual slice:
  //
  //   Tier 1: progress 0→1 maps to bar positions  0.00 → 0.35
  //   Tier 2: progress 0→1 maps to bar positions  0.35 → 0.55
  //   Tier 3: progress 0→0.9 maps to bar positions 0.55 → ~0.96
  //           (capped at 90% so the arrow never hugs the far edge)
  double get _arrowFraction {
    if (tierUsed <= baseTierLimit) {
      final p = baseTierLimit > 0
          ? (tierUsed / baseTierLimit).clamp(0.0, 1.0)
          : 0.0;
      return p * _greenEnd;
    } else if (tierUsed <= tierTwoLimit) {
      final zoneSize = tierTwoLimit - baseTierLimit;
      final p = zoneSize > 0
          ? ((tierUsed - baseTierLimit) / zoneSize).clamp(0.0, 1.0)
          : 0.0;
      return _greenEnd + p * (_yellowEnd - _greenEnd);
    } else {
      // Scale: one full tierTwoLimit-worth of overage past tier 2 = 90% of red.
      final overage = tierUsed - tierTwoLimit;
      final scale = tierTwoLimit > 0 ? tierTwoLimit : 1.0;
      final p = (overage / scale).clamp(0.0, 0.9);
      return _yellowEnd + p * (1.0 - _yellowEnd);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Used label + optional live dot ───────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${tierUsed.toStringAsFixed(2)} L used',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            if (isLive)
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: tierColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'updating live',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tierColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Bar + arrow ───────────────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final arrowLeft = (barWidth * _arrowFraction - 12).clamp(
              0.0,
              barWidth - 24,
            );

            return SizedBox(
              height: 46, // 16 arrow + 10 gap + 20 bar
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 3-zone bar with fixed flex proportions
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 35,
                            child: Container(height: 20, color: _success),
                          ),
                          Expanded(
                            flex: 20,
                            child: Container(height: 20, color: _warning),
                          ),
                          Expanded(
                            flex: 45,
                            child: Container(height: 20, color: _danger),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // White divider at green/yellow boundary
                  Positioned(
                    left: barWidth * _greenEnd,
                    top: 20,
                    child: Container(width: 2, height: 20, color: Colors.white),
                  ),

                  // White divider at yellow/red boundary
                  Positioned(
                    left: barWidth * _yellowEnd,
                    top: 20,
                    child: Container(width: 2, height: 20, color: Colors.white),
                  ),

                  // Downward arrow at the computed position
                  Positioned(
                    left: arrowLeft,
                    top: 0,
                    child: CustomPaint(
                      size: const Size(24, 16),
                      painter: _ArrowPainter(color: tierColor),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 6),

        // ── Boundary labels (actual litre values) ─────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return SizedBox(
              height: 18,
              child: Stack(
                children: [
                  // Left edge — 0
                  const Positioned(
                    left: 0,
                    child: Text(
                      '0',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      ),
                    ),
                  ),

                  // Right edge — ∞
                  const Positioned(
                    right: 0,
                    child: Text(
                      '∞',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      ),
                    ),
                  ),

                  // baseTierLimit label at green/yellow boundary
                  Positioned(
                    left: (w * _greenEnd - 12).clamp(0.0, w - 48),
                    child: Text(
                      '${baseTierLimit.toStringAsFixed(0)} L',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _success,
                      ),
                    ),
                  ),

                  // tierTwoLimit label at yellow/red boundary
                  Positioned(
                    left: (w * _yellowEnd - 12).clamp(0.0, w - 48),
                    child: Text(
                      '${tierTwoLimit.toStringAsFixed(0)} L',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _warning,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // ── Color legend ──────────────────────────────────────────────────────
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ColorLegend(color: _success, label: 'Tier 1'),
            SizedBox(width: 24),
            _ColorLegend(color: _warning, label: 'Tier 2'),
            SizedBox(width: 24),
            _ColorLegend(color: _danger, label: 'Tier 3'),
          ],
        ),
      ],
    );
  }
}

// ── Arrow painter (downward triangle) ────────────────────────────────────────

class _ArrowPainter extends CustomPainter {
  final Color color;

  const _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.color != color;
}

// ── Color legend dot ──────────────────────────────────────────────────────────

class _ColorLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}
