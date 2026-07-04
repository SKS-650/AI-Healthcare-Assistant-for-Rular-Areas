import '../../../domain/entities/prediction.dart';

class HiveSymptomStore {
  HiveSymptomStore._();

  static final instance = HiveSymptomStore._();

  final List<Prediction> _history = <Prediction>[];

  List<Prediction> loadHistory() {
    return List<Prediction>.unmodifiable(_history.reversed);
  }

  void savePrediction(Prediction prediction) {
    _history.add(prediction);
  }
}
