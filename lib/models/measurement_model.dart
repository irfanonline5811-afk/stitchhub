enum MeasurementStatus {
  pending,
  scheduled,
  completed,
  cancelled,
}

class MeasurementModel {
  final String id;
  final String customerId;
  final String tailorId;
  final String customerName;
  final String tailorName;
  final MeasurementStatus status;
  final DateTime? appointmentDate;
  final DateTime? appointmentTime;
  final String? notes;
  final Map<String, double> measurements; // chest, waist, shoulder, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  MeasurementModel({
    required this.id,
    required this.customerId,
    required this.tailorId,
    required this.customerName,
    required this.tailorName,
    this.status = MeasurementStatus.pending,
    this.appointmentDate,
    this.appointmentTime,
    this.notes,
    this.measurements = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    return MeasurementModel(
      id: map['id'] ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      tailorId: map['tailor_id'] ?? map['tailorId'] ?? '',
      customerName: map['customer_name'] ?? map['customerName'] ?? '',
      tailorName: map['tailor_name'] ?? map['tailorName'] ?? '',
      status: MeasurementStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => MeasurementStatus.pending,
      ),
      appointmentDate: map['appointment_date'] != null
          ? DateTime.parse(map['appointment_date'].toString())
          : map['appointmentDate'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['appointmentDate'])
            : null,
      appointmentTime: map['appointment_time'] != null
          ? DateTime.parse(map['appointment_time'].toString())
          : map['appointmentTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['appointmentTime'])
            : null,
      notes: map['notes'],
      measurements: Map<String, double>.from(
        (map['measurements'] ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'tailor_id': tailorId,
      'customer_name': customerName,
      'tailor_name': tailorName,
      'status': status.toString().split('.').last,
      'appointment_date': appointmentDate?.toIso8601String(),
      'appointment_time': appointmentTime?.toIso8601String(),
      'notes': notes,
      'measurements': measurements,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MeasurementModel copyWith({
    String? id,
    String? customerId,
    String? tailorId,
    String? customerName,
    String? tailorName,
    MeasurementStatus? status,
    DateTime? appointmentDate,
    DateTime? appointmentTime,
    String? notes,
    Map<String, double>? measurements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeasurementModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      tailorId: tailorId ?? this.tailorId,
      customerName: customerName ?? this.customerName,
      tailorName: tailorName ?? this.tailorName,
      status: status ?? this.status,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      notes: notes ?? this.notes,
      measurements: measurements ?? this.measurements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
