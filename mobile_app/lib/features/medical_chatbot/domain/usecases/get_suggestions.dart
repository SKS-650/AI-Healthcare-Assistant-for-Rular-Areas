import '../entities/suggestion.dart';
import '../repositories/chatbot_repository.dart';

class GetSuggestions {
  final ChatbotRepository repository;

  const GetSuggestions(this.repository);

  Future<List<Suggestion>> call() {
    return repository.getSuggestions();
  }
}
