import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/models.dart';

class UsersState {
  final bool isLoading;
  final String? error;
  final List<AdminUser> users;
  final int total;
  final int page;
  final int pageSize;
  final String search;
  final String? roleFilter;
  final bool? activeFilter;

  const UsersState({
    this.isLoading = false,
    this.error,
    this.users = const [],
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.roleFilter,
    this.activeFilter,
  });

  int get totalPages => (total / pageSize).ceil().clamp(1, 9999);

  UsersState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<AdminUser>? users,
    int? total,
    int? page,
    int? pageSize,
    String? search,
    String? roleFilter,
    bool? activeFilter,
    bool clearRole = false,
    bool clearActive = false,
  }) =>
      UsersState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        users: users ?? this.users,
        total: total ?? this.total,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        search: search ?? this.search,
        roleFilter: clearRole ? null : (roleFilter ?? this.roleFilter),
        activeFilter:
            clearActive ? null : (activeFilter ?? this.activeFilter),
      );
}

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier() : super(const UsersState()) {
    load();
  }

  Future<void> load({int? page}) async {
    state = state.copyWith(isLoading: true, clearError: true, page: page ?? state.page);
    try {
      final params = <String, dynamic>{
        'page': state.page,
        'page_size': state.pageSize,
      };
      if (state.search.isNotEmpty) params['search'] = state.search;
      if (state.roleFilter != null) params['role'] = state.roleFilter;
      if (state.activeFilter != null) params['is_active'] = state.activeFilter;

      final resp =
          await ApiClient.instance.get('/admin/users', queryParameters: params);
      final data = resp.data as Map<String, dynamic>;
      final usersList = (data['users'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(AdminUser.fromJson)
          .toList();

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        users: usersList,
        total: data['total'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: errorMessage(e));
    }
  }

  void setSearch(String v) {
    state = state.copyWith(search: v, page: 1);
    load();
  }

  void setRoleFilter(String? v) {
    state = v == null
        ? state.copyWith(clearRole: true, page: 1)
        : state.copyWith(roleFilter: v, page: 1);
    load();
  }

  void setActiveFilter(bool? v) {
    state = v == null
        ? state.copyWith(clearActive: true, page: 1)
        : state.copyWith(activeFilter: v, page: 1);
    load();
  }

  void goToPage(int p) => load(page: p);

  Future<void> updateStatus(String userId, bool isActive) async {
    try {
      await ApiClient.instance
          .patch('/admin/users/$userId/status', data: {'is_active': isActive});
      load();
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
    }
  }

  Future<void> updateRole(String userId, String role) async {
    try {
      await ApiClient.instance
          .patch('/admin/users/$userId/role', data: {'role': role});
      load();
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await ApiClient.instance.delete('/admin/users/$userId');
      load();
      return true;
    } catch (e) {
      state = state.copyWith(error: errorMessage(e));
      return false;
    }
  }
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, UsersState>(
        (ref) => UsersNotifier());
