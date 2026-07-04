import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.gender,
    super.age,
    super.language,
    super.avatarUrl,
    super.isGuest,
    super.isProfileComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        language: json['language'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        isGuest: json['isGuest'] as bool? ?? false,
        isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'gender': gender,
        'age': age,
        'language': language,
        'avatarUrl': avatarUrl,
        'isGuest': isGuest,
        'isProfileComplete': isProfileComplete,
      };

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        name: entity.name,
        phone: entity.phone,
        gender: entity.gender,
        age: entity.age,
        language: entity.language,
        avatarUrl: entity.avatarUrl,
        isGuest: entity.isGuest,
        isProfileComplete: entity.isProfileComplete,
      );
}
