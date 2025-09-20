class Topic {
  final int? id;
  final int subjectId; // Foreign key to link to the Subject table.
  final int? dateCardId; 
  final String title;
  final String notes;
  final DateTime studiedOn; // The date the topic is associated with.
  final int intervalIndex; // 0-5, maps to our SRS schedule.
  final DateTime? nextDue; // Can be null for 'mastered' topics.
  final String status; // 'active', 'mastered', 'trashed'
  final DateTime lastReviewedAt;
  final DateTime createdAt;

  Topic({
    this.id,
    required this.subjectId,
    this.dateCardId,
    required this.title,
    required this.notes,
    required this.studiedOn,
    this.intervalIndex = 0,
    this.nextDue,
    this.status = 'active',
    required this.lastReviewedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_id': subjectId,
      'date_card_id': dateCardId,
      'title': title,
      'notes': notes,
      // We store DateTimes as ISO 8601 strings. This is a robust and
      // human-readable way to store dates in a text field.
      'studied_on': studiedOn.toIso8601String(),
      'interval_index': intervalIndex,
      'next_due': nextDue?.toIso8601String(),
      'status': status,
      'last_reviewed_at': lastReviewedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'],
      subjectId: map['subject_id'],
      dateCardId: map['date_card_id'],
      title: map['title'],
      notes: map['notes'],
      // We parse the string from the database back into a DateTime object.
      studiedOn: DateTime.parse(map['studied_on']),
      intervalIndex: map['interval_index'],
      nextDue: map['next_due'] != null ? DateTime.parse(map['next_due']) : null,
      status: map['status'],
      lastReviewedAt: DateTime.parse(map['last_reviewed_at']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
  
  Topic copyWith({
    int? id,
    int? subjectId,
    int? dateCardId,
    String? title,
    String? notes,
    DateTime? studiedOn,
    int? intervalIndex,
    DateTime? nextDue,
    bool setNextDueToNull = false, // Special flag to allow setting nextDue to null
    String? status,
    DateTime? lastReviewedAt,
    DateTime? createdAt,
  }) {
    return Topic(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      dateCardId: dateCardId ?? this.dateCardId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      studiedOn: studiedOn ?? this.studiedOn,
      intervalIndex: intervalIndex ?? this.intervalIndex,
      nextDue: setNextDueToNull ? null : nextDue ?? this.nextDue,
      status: status ?? this.status,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}