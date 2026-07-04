import '../entities/symptom_form.dart';
import '../repositories/symptom_repository.dart';

class LoadSymptomForm {
  final SymptomRepository repository;

  const LoadSymptomForm(this.repository);

  Future<SymptomForm?> call() async {
    return await repository.loadSymptomForm();
  }
}