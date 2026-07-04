// lib/features/home/presentation/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/dashboard_repository.dart';
import '../controller/dashboard_controller.dart';
import '../controller/dashboard_state.dart' as dashboard_state;

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardControllerProvider = StateNotifierProvider<DashboardController, dashboard_state.DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardController(repository);
});

final dashboardTabProvider = StateProvider<int>((ref) => 0);