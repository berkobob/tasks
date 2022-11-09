class TaskList {
  String title;
  String? updated;
  String? selfLink;
  String? id;

  TaskList(this.title);

  TaskList.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        updated = (json['updated']),
        selfLink = json['selfLink'],
        id = json['id'];

  Map<String, dynamic> toJson() => {
        "title": title,
        if (updated != null) "updated": updated,
        if (selfLink != null) "selfLink": selfLink,
        if (id != null) "id": id
      };

  @override
  String toString() => 'TaskList title: $title, link $selfLink';
}
