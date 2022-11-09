class Task {
  String? kind;
  String? id;
  String? etag;
  String title;
  String? updated;
  String? selfLink;
  String? parent;
  String? position;
  String? notes;
  String? status;
  String? due;
  String? completed;
  String? deleted;
  String? hidden;
  List? links;

  Task({
    this.kind,
    this.id,
    this.etag,
    required this.title,
    this.updated,
    this.selfLink,
    this.parent,
    this.position,
    this.notes,
    this.status,
    this.due,
    this.completed,
    this.deleted,
    this.hidden,
    this.links,
  });

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

  Map<String, dynamic> toJson() => {
        if (kind != null) "kind": kind,
        if (id != null) "id": id,
        if (etag != null) "etag": etag,
        "title": title,
        if (updated != null) "updated": updated,
        if (selfLink != null) "selfLink": selfLink,
        if (parent != null) "parent": parent,
        if (position != null) "position": position,
        if (notes != null) "notes": notes,
        if (status != null) "status": status,
        if (due != null) "due": due,
        if (completed != null) "completed": completed,
        if (deleted != null) "deleted": deleted,
        if (hidden != null) "hidden": hidden,
        if (links != null) "links": links
      };

  @override
  String toString() => 'Task: $title, completed: $completed';
}
