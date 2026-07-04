import '../entities/emergency_contact.dart';
import '../repositories/emergency_repository.dart';

class GetEmergencyContacts {
  final EmergencyRepository repository;

  const GetEmergencyContacts(this.repository);

  Future<List<EmergencyContact>> call() => repository.getEmergencyContacts();
}
