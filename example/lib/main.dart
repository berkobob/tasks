import 'package:flutter/material.dart';
import 'package:tasks/tasks.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final tasks = Tasks();
  TaskList? currentList;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            FutureBuilder(
                future: tasks.hasAccess(),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  final access = snapshot.data ?? false;
                  return access
                      ? TextButton(
                          onPressed: () => setState(() {
                            currentList = null;
                          }),
                          child: const Text(
                            'Get All',
                            style: TextStyle(
                                color: Colors.white, letterSpacing: 1.0),
                          ),
                        )
                      : const Icon(Icons.cancel_rounded, color: Colors.red);
                }),
          ],
          title: Text(currentList?.title ?? ''),
        ),
        drawer: Drawer(
          child: FutureBuilder(
              future: tasks.getLists(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<TaskList>> snapshot) {
                final lists = snapshot.data ?? [];
                return ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(lists[index].title),
                        onTap: () => setState(() {
                          currentList = lists[index];
                          Navigator.of(context).pop();
                        }),
                      );
                    },
                    itemCount: lists.length);
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final TaskList list = currentList ?? await tasks.getDefaultList();
            final task = Task(title: 'Another new task', notes: "Good luck");
            await tasks.createTask(list: list, task: task);
            setState(() {});
          },
          child: const Icon(Icons.add),
        ),
        body: buildtasks(currentList?.id),
      ),
    );
  }

  Center buildtasks(String? list) {
    return Center(
      child: FutureBuilder(
          future: currentList != null
              ? tasks.getTasksForList(currentList!)
              : Future.value(<Task>[]),
          builder: (BuildContext context, AsyncSnapshot<List<Task>?> snapshot) {
            if (snapshot.hasData) {
              final List<Task> rems = snapshot.data ?? [];
              return ListView.builder(
                  itemCount: rems.length,
                  itemBuilder: (context, index) {
                    final task = rems[index];
                    return ListTile(
                      leading: Text('${task.id}'),
                      title: Row(
                        children: [
                          Expanded(child: Text(task.title)),
                          GestureDetector(
                              child: Text(task.due ?? 'No date set'),
                              onTap: () async {
                                task.due =
                                    DateTime.now().toUtc().toIso8601String();
                                await tasks.saveTask(task);
                                setState(() {});
                              })
                        ],
                      ),
                      subtitle: task.notes != null ? Text(task.notes!) : null,
                      trailing: GestureDetector(
                        child: task.completed != null
                            ? const Icon(Icons.check_box)
                            : const Icon(Icons.check_box_outline_blank),
                        onTap: () async {
                          task.completed =
                              DateTime.now().toUtc().toIso8601String();
                          task.status = 'completed';
                          await tasks.saveTask(task);
                          setState(() {});
                        },
                      ),
                      onLongPress: () async {
                        await tasks.deleteTask(task);
                        setState(() {});
                      },
                    );
                  });
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
