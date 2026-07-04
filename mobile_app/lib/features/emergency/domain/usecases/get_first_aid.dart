import '../entities/first_aid.dart';
import '../repositories/emergency_repository.dart';

class GetFirstAid {
  final EmergencyRepository repository;

  const GetFirstAid(this.repository);

  Future<List<FirstAid>> call() => repository.getFirstAid();
}
