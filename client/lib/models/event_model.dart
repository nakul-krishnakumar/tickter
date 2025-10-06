class Event {
  final String id;
  final String eventName;
  final String? description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String source;
  final List<int> batch;
  final List<int> semester;
  final String type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.eventName,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.source,
    required this.batch,
    required this.semester,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      eventName: json['event_name'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      source: json['source'] as String,
      batch: (json['batch'] as List<dynamic>).cast<int>(),
      semester: (json['semester'] as List<dynamic>).cast<int>(),
      type: json['type'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_name': eventName,
      'description': description,
      'date': date.toIso8601String().split('T')[0], // Date only
      'start_time': startTime,
      'end_time': endTime,
      'source': source,
      'batch': batch,
      'semester': semester,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    String timeStr = '';
    if (startTime != null && endTime != null) {
      timeStr = ' ($startTime - $endTime)';
    } else if (startTime != null) {
      timeStr = ' ($startTime)';
    }
    return '$eventName$timeStr';
  }
}
