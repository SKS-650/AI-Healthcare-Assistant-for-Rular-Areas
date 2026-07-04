import 'package:flutter/material.dart';
import '../../../../../shared/design_system/design_tokens.dart';
import '../../../domain/entities/hospital.dart';

const _cardGrads = [
  [Color(0xFF926EFF), Color(0xFF6B47E8)],
  [Color(0xFF4F94FF), Color(0xFF2563EB)],
  [Color(0xFF2ECC8B), Color(0xFF16A34A)],
  [Color(0xFF18C8C8), Color(0xFF0B9B9B)],
  [Color(0xFFFF7B3D), Color(0xFFE55A1A)],
];

class NearbyHospitalsList extends StatelessWidget {
  final List<Hospital> hospitals;
  const NearbyHospitalsList({super.key, required this.hospitals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: hospitals.length,
        itemBuilder: (context, i) =>
            _HospitalCard(hospital: hospitals[i], index: i),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final int index;
  const _HospitalCard({required this.hospital, required this.index});

  @override
  Widget build(BuildContext context) {
    final grad = _cardGrads[index % _cardGrads.length];
    return Container(
      width: 188,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            grad[0].withValues(alpha: 0.08),
            grad[1].withValues(alpha: 0.04)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: grad[0].withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: grad[0].withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [grad[0], grad[1]],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: grad[0].withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: const Center(
                        child: Text('🏥', style: TextStyle(fontSize: 18))),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: DesignTokens.greenContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: DesignTokens.green.withValues(alpha: 0.3))),
                    child: Text('24/7',
                        style: TextStyle(
                            color: DesignTokens.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(hospital.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: DesignTokens.textStrong,
                        letterSpacing: -0.2)),
                const SizedBox(height: 3),
                Text(hospital.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: DesignTokens.textMuted, fontSize: 11)),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.near_me_rounded, size: 12, color: grad[0]),
                  const SizedBox(width: 4),
                  Text('${hospital.distance} km away',
                      style: TextStyle(
                          color: grad[0],
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
