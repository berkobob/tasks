import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:tasks/src/authentication_service.dart';
import 'package:tasks/tasks.dart';
import 'package:http/http.dart' as http;

/// The [Tasks] API provides async access to Google [Task]s
class Tasks {
  static const String rootUrl = 'https://tasks.googleapis.com/tasks/v1';
  static const String suffix = '?maxResults=1000';
  final _authentication = Authentication();
  final log = Logger();

  /// Whether access to Google Tasks API is available
  Future<bool> hasAccess() async {
    try {
      await _authentication.headers;
      return true;
    } catch (e) {
      log.e('Error getting authentication headers', AssertionError(e));
      return false;
    }
  }

  /// Returns a list of the [TaskList]s available
  Future<List<TaskList>> getLists() async {
    final uri = Uri.parse('$rootUrl/users/@me/lists$suffix');
    final response =
        await http.get(uri, headers: await _authentication.headers);

    if (response.statusCode != 200) {
      throw 'Failed to get lists: ${response.reasonPhrase}';
    }

    return jsonDecode(response.body)['items']
        .map<TaskList>((json) => TaskList.fromJson(json))
        .toList();
  }

  /// Returns the default [TaskList] which cannot be deleted and will be used
  /// if no list is specified when creating a [Task].
  Future<TaskList> getDefaultList() async {
    final lists = await getLists();
    return lists.first;
  }

  /// Returns the [Task]s belonging to a [TaskList]
  /// [options] parameters are documented [here](https://developers.google.com/tasks/reference/rest/v1/tasks/list)
  Future<List<Task>> getTasksForList(TaskList list,
      {String options = ''}) async {
    final uri = Uri.parse('$rootUrl/lists/${list.id}/tasks$suffix$options');

    final response =
        await http.get(uri, headers: await _authentication.headers);

    if (response.statusCode != 200) {
      throw 'Failed to get Tasks in ${list.title}';
    }

    return jsonDecode(response.body)['items']
        .map<Task>((json) => Task.fromJson(json))
        .toList();
  }

  /// Creates a new [Task] for a specified [TaskList]
  Future<Task> createTask({required TaskList list, required Task task}) async {
    final headers = await _authentication.headers;
    final body = jsonEncode(task.toJson());

    final uri = Uri.parse('$rootUrl/lists/${list.id}/tasks');
    final response = await http.post(uri, headers: headers, body: body);
    final reply = jsonDecode(response.body);

    if (response.statusCode != 200) {
      log.i(reply);
      throw 'Failed to save task: ${task.title}\n$reply';
    }

    return Task.fromJson(reply);
  }

  /// Save changes made to a [Task]
  Future saveTask(Task task) async {
    final headers = await _authentication.headers;
    final body = jsonEncode(task.toJson());

    final uri = Uri.parse(task.selfLink!);
    final response = await http.put(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      final reply = jsonDecode(response.body);
      throw 'Failed to save task: ${task.title}\n$reply\n$body';
    }
  }

  /// Delete a [Task]
  Future deleteTask(Task task) async {
    final response = await http.delete(Uri.parse(task.selfLink!),
        headers: await _authentication.headers);

    if (response.statusCode != 204) {
      throw 'Failed to delete task.\n${jsonDecode(response.body)}\n${task.toJson()}';
    }
  }
}
