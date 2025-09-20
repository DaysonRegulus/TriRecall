class DateCard {
  final int? id;
  final DateTime studyDate; // The specific date this card represents, e.g., Sep 1, 2025
  final int intervalIndex;
  final DateTime? nextDue;
  final String status; // 'active', 'mastered'
  final bool isIncomplete; // Our new flag for data entry tracking

  DateCard({
    this.id,
    required this.studyDate,
    this.intervalIndex = 0,
    this.nextDue,
    this.status = 'active',
    this.isIncomplete = true, // Defaults to incomplete
  });

  // A copyWith method is essential for easily creating updated versions of the object.
  DateCard copyWith({
    int? id,
    DateTime? studyDate,
    int? intervalIndex,
    DateTime? nextDue,
    bool setNextDueToNull = false,
    String? status,
    bool? isIncomplete,
  }) {
    return DateCard(
      id: id ?? this.id,
      studyDate: studyDate ?? this.studyDate,
      intervalIndex: intervalIndex ?? this.intervalIndex,
      nextDue: setNextDueToNull ? null : nextDue ?? this.nextDue,
      status: status ?? this.status,
      isIncomplete: isIncomplete ?? this.isIncomplete,
    );
  }

  // Methods to convert between a Dart object and a Map for the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'study_date': studyDate.toIso8601String(),
      'interval_index': intervalIndex,
      'next_due': nextDue?.toIso8601String(),
      'status': status,
      // SQLite doesn't have a boolean type, so we store it as an integer (0 or 1).
      'is_incomplete': isIncomplete ? 1 : 0,
    };
  }

  factory DateCard.fromMap(Map<String, dynamic> map) {
    return DateCard(
      id: map['id'],
      studyDate: DateTime.parse(map['study_date']),
      intervalIndex: map['interval_index'],
      nextDue: map['next_due'] != null ? DateTime.parse(map['next_due']) : null,
      status: map['status'],
      // Convert the integer back to a boolean.
      isIncomplete: map['is_incomplete'] == 1,
    );
  }
}