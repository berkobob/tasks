class Task {
  String kind;
  String id;
  String etag;
  String title;
  String updated;
  String selfLink;
  String parent;
  String position;
  String notes;
  String status;
  String due;
  String completed;
  String deleted;
  String hidden;
  List<Map<String, String>> links;

  Task.fromJson(Map<String, dynamic> json)
      : kind = json["kind"],
        id = json["id"],
        etag = json["etag"],
        title = json["title"],
        updated = json["updated"],
        selfLink = json["selfLink"],
        parent = json["parent"],
        position = json["position"],
        notes = json["notes"],
        status = json["status"],
        due = json["due"],
        completed = json["completed"],
        deleted = json["deleted"],
        hidden = json["hidden"],
        links = json["links"];
}
