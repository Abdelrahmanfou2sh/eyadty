class RecurrencePattern {
  final String type; // daily, weekly, monthly
  final int interval; // كل كم يوم/أسبوع/شهر
  final DateTime? endDate; // تاريخ انتهاء التكرار (اختياري)
  final int? occurrences; // عدد مرات التكرار (اختياري)

  RecurrencePattern({
    required this.type,
    required this.interval,
    this.endDate,
    this.occurrences,
  }) {
    assert(
      (endDate == null && occurrences == null) || 
      (endDate != null && occurrences == null) || 
      (endDate == null && occurrences != null),
      'يجب تحديد إما تاريخ الانتهاء أو عدد مرات التكرار، وليس كلاهما',
    );
  }

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      type: json['type'] as String,
      interval: json['interval'] as int,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      occurrences: json['occurrences'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'interval': interval,
      'endDate': endDate?.toIso8601String(),
      'occurrences': occurrences,
    };
  }
}

class AppointmentModel {
  final String id;
  final String patientName;
  final String phoneNumber;
  final String date;
  final String time;
  final String appointmentType;
  final String status;
  final RecurrencePattern? recurrence; // إضافة نمط التكرار
  final String? parentAppointmentId; // معرف الموعد الأصلي في حالة المواعيد المتكررة

  AppointmentModel({
    required this.id,
    required this.patientName,
    required this.phoneNumber,
    required this.date,
    required this.time,
    required this.appointmentType,
    required this.status,
    this.recurrence,
    this.parentAppointmentId,
  });

  factory AppointmentModel.fromJson(String id, Map<String, dynamic> json) {
    return AppointmentModel(
      id: id,
      patientName: json['patientName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      appointmentType: json['appointmentType'] as String,
      status: json['status'] as String,
      recurrence: json['recurrence'] != null 
          ? RecurrencePattern.fromJson(json['recurrence'] as Map<String, dynamic>)
          : null,
      parentAppointmentId: json['parentAppointmentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'date': date,
      'time': time,
      'appointmentType': appointmentType,
      'status': status,
      'recurrence': recurrence?.toJson(),
      'parentAppointmentId': parentAppointmentId,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientName,
    String? phoneNumber,
    String? date,
    String? time,
    String? appointmentType,
    String? status,
    RecurrencePattern? recurrence,
    String? parentAppointmentId,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      date: date ?? this.date,
      time: time ?? this.time,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      recurrence: recurrence ?? this.recurrence,
      parentAppointmentId: parentAppointmentId ?? this.parentAppointmentId,
    );
  }

  /// إنشاء سلسلة من المواعيد المتكررة
  List<AppointmentModel> generateRecurringAppointments() {
    if (recurrence == null) return [this];

    final appointments = <AppointmentModel>[];
    var currentDate = DateTime.parse(date);
    var count = 0;

    while (true) {
      // التحقق من شروط التوقف
      if (recurrence!.endDate != null && currentDate.isAfter(recurrence!.endDate!)) {
        break;
      }
      if (recurrence!.occurrences != null && count >= recurrence!.occurrences!) {
        break;
      }

      // إضافة موعد جديد
      if (count > 0) { // تخطي الموعد الأول لأنه هذا الموعد نفسه
        appointments.add(copyWith(
          id: '', // سيتم تعيينه عند الحفظ في Firebase
          date: currentDate.toIso8601String().split('T')[0],
          parentAppointmentId: id,
        ));
      }

      // حساب الموعد التالي
      switch (recurrence!.type) {
        case 'daily':
          currentDate = currentDate.add(Duration(days: recurrence!.interval));
          break;
        case 'weekly':
          currentDate = currentDate.add(Duration(days: 7 * recurrence!.interval));
          break;
        case 'monthly':
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + recurrence!.interval,
            currentDate.day,
          );
          break;
      }

      count++;
    }

    return appointments;
  }
}