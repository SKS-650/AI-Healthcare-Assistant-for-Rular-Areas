import 'package:equatable/equatable.dart';

class Symptom extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;

  const Symptom({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, category, description];
}