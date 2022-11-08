import 'dart:convert';
import 'package:tasks/src/authentication_service.dart';
import 'package:tasks/tasks.dart';
import 'package:http/http.dart' as http;

class Tasks {
  final authentication = Authentication();

  Future<List<TaskList>> getLists() async {
    final uri =
        Uri.parse('https://tasks.googleapis.com/tasks/v1/users/@me/lists');

    final response = await http.get(uri, headers: await authentication.headers);

    if (response.statusCode != 200) {
      throw 'Failed to get lists: ${response.reasonPhrase}';
    }

    return jsonDecode(response.body)['items']
        .map<TaskList>((json) => TaskList.fromJson(json))
        .toList();
  }
}
