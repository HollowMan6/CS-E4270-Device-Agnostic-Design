import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz/class/question.dart';
import 'package:quiz/class/topic.dart';

class QuizService {
  final _baseUrl = 'https://dad-quiz-api.deno.dev';

  Future<List<Topic>> getTopics() async {
    var response = await http.get(Uri.parse('$_baseUrl/topics'));
    List<dynamic> topicItems = jsonDecode(response.body);
    return List<Topic>.from(
        topicItems.map((jsonData) => Topic.fromJson(jsonData)));
  }

  Future<Question> getQuestion(int topicId) async {
    var response =
        await http.get(Uri.parse('$_baseUrl/topics/$topicId/questions'));
    var data = jsonDecode(response.body);

    return Question.fromJson(data);
  }

  Future<bool> checkAnswer(int topicId, int questioId, String answer) async {
    var response = await http.post(
        Uri.parse('$_baseUrl/topics/$topicId/questions/$questioId/answers'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"answer": answer}));
    var data = jsonDecode(response.body);
    return data['correct'];
  }
}
