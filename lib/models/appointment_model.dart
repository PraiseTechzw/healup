enum AppointmentStatus { pending, confirmed, completed, cancelled, rescheduled }

enum AppointmentType { consultation, followup, emergency, routine }

class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentStatus status;
  final AppointmentType type;
  final String? reason;
  final String? notes;
  final double consultationFee;
  final String? paymentStatus;
  final String? paymentId;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? prescription;
  final List<String> attachments;
  final Map<String, dynamic> vitals;
  final String? diagnosis;
  final String? treatment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.type,
    this.reason,
    this.notes,
    required this.consultationFee,
    this.paymentStatus,
    this.paymentId,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.prescription,
    required this.attachments,
    required this.vitals,
    this.diagnosis,
    this.treatment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromMap(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      patientEmail: data['patientEmail'] ?? '',
      appointmentDate: data['appointmentDate']?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${data['status']}',
        orElse: () => AppointmentStatus.pending,
      ),
      type: AppointmentType.values.firstWhere(
        (e) => e.toString() == 'AppointmentType.${data['type']}',
        orElse: () => AppointmentType.consultation,
      ),
      reason: data['reason'],
      notes: data['notes'],
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      paymentStatus: data['paymentStatus'],
      paymentId: data['paymentId'],
      confirmedAt: data['confirmedAt']?.toDate(),
      completedAt: data['completedAt']?.toDate(),
      cancelledAt: data['cancelledAt']?.toDate(),
      cancellationReason: data['cancellationReason'],
      prescription: data['prescription'],
      attachments: List<String>.from(data['attachments'] ?? []),
      vitals: Map<String, dynamic>.from(data['vitals'] ?? {}),
      diagnosis: data['diagnosis'],
      treatment: data['treatment'],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientEmail': patientEmail,
      'appointmentDate': appointmentDate,
      'timeSlot': timeSlot,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'reason': reason,
      'notes': notes,
      'consultationFee': consultationFee,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'confirmedAt': confirmedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
      'prescription': prescription,
      'attachments': attachments,
      'vitals': vitals,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? patientEmail,
    DateTime? appointmentDate,
    String? timeSlot,
    AppointmentStatus? status,
    AppointmentType? type,
    String? reason,
    String? notes,
    double? consultationFee,
    String? paymentStatus,
    String? paymentId,
    DateTime? confirmedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? prescription,
    List<String>? attachments,
    Map<String, dynamic>? vitals,
    String? diagnosis,
    String? treatment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      consultationFee: consultationFee ?? this.consultationFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      prescription: prescription ?? this.prescription,
      attachments: attachments ?? this.attachments,
      vitals: vitals ?? this.vitals,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
