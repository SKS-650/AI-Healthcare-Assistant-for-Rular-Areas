import 'package:flutter/material.dart';

import '../../../../../shared/design_system/design_tokens.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Row(
          children: [
            Text('👤', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'My Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DesignTokens.textStrong,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: DesignTokens.primary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // Profile Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignTokens.primary, DesignTokens.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2),
                        ),
                        child: const Center(
                          child:
                              Text('👤', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: DesignTokens.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ramesh Kumar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Age 34 • Male • Blood: O+',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                size: 12, color: Colors.white70),
                            SizedBox(width: 3),
                            Text(
                              'Village Rampur, Uttar Pradesh',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Health Stats
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _StatCard(
                      emoji: '❤️', label: 'Health Score', value: '78/100'),
                  const SizedBox(width: 10),
                  _StatCard(
                      emoji: '🧬', label: 'Predictions', value: '12'),
                  const SizedBox(width: 10),
                  _StatCard(
                      emoji: '📋', label: 'Records', value: '5'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            _SectionHeader(emoji: '👤', title: 'Personal Information'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _InfoRow(label: 'Full Name', value: 'Ramesh Kumar', emoji: '👤'),
                  _InfoRow(label: 'Age', value: '34 years', emoji: '🎂'),
                  _InfoRow(label: 'Gender', value: 'Male', emoji: '⚧️'),
                  _InfoRow(label: 'Blood Group', value: 'O Positive', emoji: '🩸'),
                  _InfoRow(label: 'Phone', value: '+91 98765 43210', emoji: '📱'),
                  _InfoRow(label: 'Village', value: 'Rampur, UP', emoji: '🏡'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Medical Information
            _SectionHeader(emoji: '🏥', title: 'Medical Information'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _InfoRow(
                      label: 'Chronic Conditions',
                      value: 'Hypertension',
                      emoji: '💊'),
                  _InfoRow(
                      label: 'Allergies', value: 'None known', emoji: '⚠️'),
                  _InfoRow(
                      label: 'Current Medications',
                      value: 'Amlodipine 5mg',
                      emoji: '💉'),
                  _InfoRow(
                      label: 'Emergency Contact',
                      value: 'Sita Devi • +91 87654 32109',
                      emoji: '📞'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lifestyle
            _SectionHeader(emoji: '🏃', title: 'Lifestyle'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _InfoRow(
                      label: 'Smoking', value: 'Never', emoji: '🚭'),
                  _InfoRow(
                      label: 'Alcohol', value: 'Occasional', emoji: '🥛'),
                  _InfoRow(
                      label: 'Exercise', value: 'Medium', emoji: '🏋️'),
                  _InfoRow(
                      label: 'Sleep', value: '7 hours/night', emoji: '😴'),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, label, value;
  const _StatCard(
      {required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: DesignTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DesignTokens.border),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: DesignTokens.textStrong,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: DesignTokens.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String emoji, title;
  const _SectionHeader({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textStrong,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value, emoji;
  const _InfoRow(
      {required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  color: DesignTokens.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: DesignTokens.textStrong,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
