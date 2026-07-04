import 'package:flutter/material.dart';
import '../../../../shared/design_system/design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_strings.dart';
import '../../../../routing/route_names.dart';
import '../controllers/symptom_state.dart';
import '../providers/symptom_provider.dart';

class SymptomPage extends ConsumerWidget {
  const SymptomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(symptomControllerProvider);
    final notifier = ref.read(symptomControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(AppStrings.symptomChecker),
        actions: [
          IconButton(
            tooltip: AppStrings.history,
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.history),
          ),
        ],
      ),
      body: state.status == SymptomStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  AppStrings.splashTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(AppStrings.splashSubtitle),
                const SizedBox(height: 24),
                Text(
                  'Select symptoms',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...state.availableSymptoms.map(
                  (symptom) => CheckboxListTile(
                    title: Text(symptom.name),
                    subtitle: Text(symptom.category),
                    value: state.selectedSymptoms.any((item) => item.symptom.id == symptom.id),
                    onChanged: (_) => notifier.toggleSymptomSelection(symptom),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: state.selectedSymptoms.isEmpty
                      ? null
                      : () {
                          notifier.nextStep();
                          Navigator.of(context).pushNamed(RouteNames.symptomChecker);
                        },
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Open symptom checker flow'),
                ),
              ],
            ),
    );
  }
}
