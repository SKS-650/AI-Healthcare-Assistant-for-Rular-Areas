import '../../domain/entities/report_category.dart';

class ReportCategoryModel extends ReportCategory {
  const ReportCategoryModel({
    required super.id,
    required super.name,
    required super.count,
    required super.description,
  });
}
