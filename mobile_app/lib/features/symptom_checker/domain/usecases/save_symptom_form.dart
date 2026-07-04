import '../entities/symptom_form.dart';
import '../repositories/symptom_repository.dart';

class SaveSymptomForm {
  final SymptomRepository repository;

  const SaveSymptomForm(this.repository);

  Future<void> call(SymptomForm form) async {
    return await repository.saveSymptomForm(form);
  }
}