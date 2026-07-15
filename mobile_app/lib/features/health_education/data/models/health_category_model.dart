import '../../domain/entities/health_category.dart';

class HealthCategoryModel extends HealthCategory {
  const HealthCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.icon,
    super.description,
    super.colorHex,
    required super.sortOrder,
    required super.isActive,
  });

  factory HealthCategoryModel.fromJson(Map<String, dynamic> json) {
    return HealthCategoryModel(
      id:          json['id'] as String,
      name:        json['name'] as String,
      slug:        json['slug'] as String,
      icon:        json['icon'] as String?,
      description: json['description'] as String?,
      colorHex:    json['color_hex'] as String?,
      sortOrder:   (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive:    json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':          id,
        'name':        name,
        'slug':        slug,
        'icon':        icon,
        'description': description,
        'color_hex':   colorHex,
        'sort_order':  sortOrder,
        'is_active':   isActive,
      };

  factory HealthCategoryModel.fromEntity(HealthCategory e) => HealthCategoryModel(
        id: e.id, name: e.name, slug: e.slug,
        icon: e.icon, description: e.description, colorHex: e.colorHex,
        sortOrder: e.sortOrder, isActive: e.isActive,
      );
}
