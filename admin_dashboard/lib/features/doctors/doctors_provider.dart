import 'package:flutter/foundation.dart';
import '../../core/api.dart';

class Doctor {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLogin;

  Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.isActive,
    required this.emailVerified,
    required this.phoneVerified,
    this.profileImage,
    required this.createdAt,
    this.lastLogin,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      isActive: json['is_active'] ?? true,
      emailVerified: json['email_verified'] ?? false,
      phoneVerified: json['phone_verified'] ?? false,
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
    );
  }
}

class DoctorsProvider with ChangeNotifier {
  final ApiClient _api;

  DoctorsProvider(this._api);

  List<Doctor> _doctors = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  String? _searchQuery;
  bool? _isActiveFilter;

  List<Doctor> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;

  Future<void> loadDoctors({
    int page = 1,
    String? search,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    _searchQuery = search;
    _isActiveFilter = isActive;
    notifyListeners();

    try {
      final params = {
        'page': page.toString(),
        'page_size': '20',
        if (search != null && search.isNotEmpty) 'search': search,
        if (isActive != null) 'is_active': isActive.toString(),
      };

      final response = await _api.get('/admin/doctors', queryParams: params);
      
      _doctors = (response['doctors'] as List)
          .map((json) => Doctor.fromJson(json))
          .toList();
      _currentPage = response['page'] ?? 1;
      _totalPages = response['total_pages'] ?? 1;
      _total = response['total'] ?? 0;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _doctors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDoctor({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      await _api.post('/admin/doctors', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      });
      await loadDoctors(page: _currentPage, search: _searchQuery, isActive: _isActiveFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDoctorStatus(String doctorId, bool isActive) async {
    try {
      await _api.patch('/admin/doctors/$doctorId/status', data: {
        'is_active': isActive,
      });
      await loadDoctors(page: _currentPage, search: _searchQuery, isActive: _isActiveFilter);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
