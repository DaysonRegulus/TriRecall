class Subject {
  final int? id; // Can be null if the subject hasn't been saved to the DB yet.
  final String title;
  final String color; // Stored as a hex string e.g., '#FFFFFF'

  Subject({
    this.id,
    required this.title,
    required this.color,
  });

  // Converts a Subject object into a Map. The keys must correspond to the names
  // of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'color': color,
    };
  }

  // A factory constructor that creates a Subject from a Map.
  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      title: map['title'],
      color: map['color'],
    );
  }

  Subject copyWith({
    int? id,
    String? title,
    String? color,
  }) {
    return Subject(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
    );
  }
}