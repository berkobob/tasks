import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tasks/src/authentication_service.dart';
import 'package:tasks/tasks.dart';
import 'package:http/http.dart' as http;

class Tasks {
  static const String rootUrl = 'https://tasks.googleapis.com/tasks/v1';
  static const String suffix = '?maxResults=1000';
  final authentication = Authentication();

  Future<bool> hasAccess() async {
    try {
      await authentication.headers;
      return true;
    } catch (e) {
      debugPrint('$e');
      return false;
    }
  }

  Future<List<TaskList>> getLists() async {
    final uri = Uri.parse('$rootUrl/users/@me/lists$suffix');
    debugPrint(uri.toString());
    final response = await http.get(uri, headers: await authentication.headers);

    if (response.statusCode != 200) {
      throw 'Failed to get lists: ${response.reasonPhrase}';
    }

    return jsonDecode(response.body)['items']
        .map<TaskList>((json) => TaskList.fromJson(json))
        .toList();
  }

  Future<TaskList> getDefaultList() async {
    final lists = await getLists();
    return lists.first;
  }

  Future<List<Task>> getTasksForList(TaskList list,
      {String options = ''}) async {
    final uri = Uri.parse('$rootUrl/lists/${list.id}/tasks$suffix$options');

    final response = await http.get(uri, headers: await authentication.headers);

    if (response.statusCode != 200) {
      throw 'Failed to get Tasks in ${list.title}';
    }

    return jsonDecode(response.body)['items']
        .map<Task>((json) => Task.fromJson(json))
        .toList();
  }

  Future<Task> createTask({required TaskList list, required Task task}) async {
    final headers = await authentication.headers;
    final body = jsonEncode(task.toJson());

    final uri = Uri.parse('$rootUrl/lists/${list.id}/tasks');
    final response = await http.post(uri, headers: headers, body: body);
    final reply = jsonDecode(response.body);

    if (response.statusCode != 200) {
      debugPrint(reply.toString());
      throw 'Failed to save task: ${task.title}\n$reply';
    }

    return Task.fromJson(reply);
  }

  Future saveTask(Task task) async {
    final headers = await authentication.headers;
    final body = jsonEncode(task.toJson());

    final uri = Uri.parse(task.selfLink!);
    final response = await http.put(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      final reply = jsonDecode(response.body);
      throw 'Failed to save task: ${task.title}\n$reply\n$body';
    }
  }

  Future deleteTask(Task task) async {
    final response = await http.delete(Uri.parse(task.selfLink!),
        headers: await authentication.headers);

    if (response.statusCode != 204) {
      throw 'Failed to delete task.\n${jsonDecode(response.body)}\n${task.toJson()}';
    }
  }
}
