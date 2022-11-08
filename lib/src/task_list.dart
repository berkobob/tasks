class TaskList {
  String title;
  String updated;
  String selfLink;
  String? id;

  TaskList(
      {required this.title,
      required this.updated,
      required this.selfLink,
      this.id});

  TaskList.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        updated = (json['updated']),
        selfLink = json['selfLink'],
        id = json['id'];

  @override
  String toString() => 'TaskList title: $title, link $selfLink';
}
