import '../../../domain/entities/symptom.dart';

class SymptomApi {
  const SymptomApi();

  Future<List<Symptom>> fetchSymptoms() async {
    return const [
      Symptom(
        id: 'fever',
        name: 'Fever',
        description: 'High body temperature or chills.',
        category: 'General',
      ),
      Symptom(
        id: 'cough',
        name: 'Cough',
        description: 'Dry or productive coughing.',
        category: 'Respiratory',
      ),
      Symptom(
        id: 'headache',
        name: 'Headache',
        description: 'Pain or pressure in the head.',
        category: 'Neurological',
      ),
      Symptom(
        id: 'fatigue',
        name: 'Fatigue',
        description: 'Unusual tiredness or weakness.',
        category: 'General',
      ),
      Symptom(
        id: 'sore_throat',
        name: 'Sore throat',
        description: 'Pain, scratchiness, or irritation in the throat.',
        category: 'Respiratory',
      ),
      Symptom(
        id: 'breathing',
        name: 'Shortness of breath',
        description: 'Difficulty breathing or chest tightness.',
        category: 'Emergency',
      ),
    ];
  }
}
