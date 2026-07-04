import '../entities/emergency_history.dart';
import '../repositories/emergency_repository.dart';

class SaveEmergencyHistory {
  final EmergencyRepository repository;

  const SaveEmergencyHistory(this.repository);

  Future<void> call(EmergencyHistory history) {
    return repository.saveEmergencyHistory(history);
  }
}
