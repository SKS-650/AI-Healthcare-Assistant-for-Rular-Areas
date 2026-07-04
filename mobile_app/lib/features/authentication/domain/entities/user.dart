import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? gender;
  final int? age;
  final String? language;
  final String? avatarUrl;
  final bool isGuest;
  final bool isProfileComplete;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.gender,
    this.age,
    this.language,
    this.avatarUrl,
    this.isGuest = false,
    this.isProfileComplete = false,
  });

  static const UserEntity empty = UserEntity(id: '', email: '');

  bool get isEmpty => id.isEmpty;

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? gender,
    int? age,
    String? language,
    String? avatarUrl,
    bool? isGuest,
    bool? isProfileComplete,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      language: language ?? this.language,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        phone,
        gender,
        age,
        language,
        avatarUrl,
        isGuest,
        isProfileComplete,
      ];
}
