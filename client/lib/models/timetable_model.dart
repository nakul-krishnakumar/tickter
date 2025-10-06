class Timetable {
  final String id;
  final int semester;
  final String course;
  final String courseCode;
  final String batch;
  final String academicYear;

  Timetable({
    required this.id,
    required this.semester,
    required this.course,
    required this.courseCode,
    required this.batch,
    required this.academicYear,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    return Timetable(
      id: json['id'] as String,
      semester: json['semester'] as int,
      course: json['course'] as String,
      courseCode: json['course_code'] as String,
      batch: json['batch'] as String,
      academicYear: json['academic_year'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': semester,
      'course': course,
      'course_code': courseCode,
      'batch': batch,
      'academic_year': academicYear,
    };
  }
}

class TimetablePeriod {
  final String id;
  final String? timetableId;
  final String day;
  final String startTime;
  final String endTime;
  final String? subjectCode;
  final String? subjectName;
  final String? subjectType;
  final String? faculty;
  final String? room;

  TimetablePeriod({
    required this.id,
    this.timetableId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.subjectCode,
    this.subjectName,
    this.subjectType,
    this.faculty,
    this.room,
  });

  factory TimetablePeriod.fromJson(Map<String, dynamic> json) {
    return TimetablePeriod(
      id: json['id'] as String,
      timetableId: json['timetable_id'] as String?,
      day: json['day'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      subjectCode: json['subject_code'] as String?,
      subjectName: json['subject_name'] as String?,
      subjectType: json['subject_type'] as String?,
      faculty: json['faculty'] as String?,
      room: json['room'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timetable_id': timetableId,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'subject_type': subjectType,
      'faculty': faculty,
      'room': room,
    };
  }

  @override
  String toString() {
    return '$subjectName ($startTime - $endTime)';
  }
}
