import '../models/user_model.dart';
import '../../domain/exceptions/auth_exception.dart';

/// In-memory fake back-end for local development.
/// Replace with real Firebase / REST calls when the backend is ready.
class AuthDummyData {
  AuthDummyData._();

  // Seed users  — {email: password}
  static final Map<String, String> _credentials = {
    'demo@health.ai': 'Password@1',
    'admin@health.ai': 'Admin@123',
  };

  static final Map<String, UserModel> _users = {
    'demo@health.ai': const UserModel(
      id: 'u_001',
      email: 'demo@health.ai',
      name: 'Demo User',
      isProfileComplete: true,
    ),
    'admin@health.ai': const UserModel(
      id: 'u_002',
      email: 'admin@health.ai',
      name: 'Admin',
      isProfileComplete: true,
    ),
  };

  // Pending OTP store: email -> otp
  static final Map<String, String> _otpStore = {};

  // Reset token store: token -> email
  static final Map<String, String> _resetTokens = {};

  /// Simulate network delay.
  static Future<void> _delay([int ms = 900]) =>
      Future.delayed(Duration(milliseconds: ms));

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<UserModel> login(String email, String password) async {
    await _delay();
    final stored = _credentials[email.toLowerCase()];
    if (stored == null || stored != password) {
      throw AuthException('Invalid email or password.');
    }
    return _users[email.toLowerCase()]!;
  }

  static Future<UserModel> register(
    String name,
    String email,
    String password,
  ) async {
    await _delay();
    final key = email.toLowerCase();
    if (_credentials.containsKey(key)) {
      throw AuthException('An account with this email already exists.');
    }
    final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(id: id, email: key, name: name);
    _credentials[key] = password;
    _users[key] = user;
    return user;
  }

  static Future<UserModel> loginAsGuest() async {
    await _delay(400);
    return const UserModel(
      id: 'guest',
      email: 'guest@health.ai',
      name: 'Guest',
      isGuest: true,
    );
  }

  static Future<void> forgotPassword(String email) async {
    await _delay(800);
    // In a real app this sends an email/SMS. We just store a fake OTP.
    _otpStore[email.toLowerCase()] = '123456';
  }

  static Future<String> verifyOtp(String email, String otp) async {
    await _delay(700);
    final stored = _otpStore[email.toLowerCase()];
    if (stored == null || stored != otp) {
      throw AuthException('Invalid or expired OTP.');
    }
    final token = 'rt_${DateTime.now().millisecondsSinceEpoch}';
    _resetTokens[token] = email.toLowerCase();
    _otpStore.remove(email.toLowerCase());
    return token;
  }

  static Future<void> resetPassword(
    String resetToken,
    String newPassword,
  ) async {
    await _delay(800);
    final email = _resetTokens[resetToken];
    if (email == null) throw AuthException('Invalid or expired reset token.');
    _credentials[email] = newPassword;
    _resetTokens.remove(resetToken);
  }

  static Future<UserModel> completeProfile(
    String userId,
    String name,
    String? phone,
    String? gender,
    int? age,
    String? language,
  ) async {
    await _delay(700);
    // Find and update user
    final entry = _users.entries.firstWhere(
      (e) => e.value.id == userId,
      orElse: () => throw AuthException('User not found.'),
    );
    final updated = UserModel(
      id: entry.value.id,
      email: entry.value.email,
      name: name,
      phone: phone,
      gender: gender,
      age: age,
      language: language,
      isProfileComplete: true,
    );
    _users[entry.key] = updated;
    return updated;
  }
}

// AuthException is defined in domain/exceptions/auth_exception.dart
