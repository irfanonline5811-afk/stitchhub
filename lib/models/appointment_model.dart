enum AppointmentStatus {
  pending,
  approved,
  declined,
  cancelled,
  completed,
}

class AppointmentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String tailorId;
  final String tailorName;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final AppointmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.tailorId,
    required this.tailorName,
    required this.startTime,
    required this.endTime,
    this.notes,
    this.status = AppointmentStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      customerName: map['customer_name'] ?? map['customerName'] ?? '',
      tailorId: map['tailor_id'] ?? map['tailorId'] ?? '',
      tailorName: map['tailor_name'] ?? map['tailorName'] ?? '',
      startTime: map['start_time'] != null
          ? DateTime.parse(map['start_time'].toString())
          : map['appointment_date'] != null 
              ? DateTime.parse(map['appointment_date'].toString())
              : DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: map['end_time'] != null
          ? DateTime.parse(map['end_time'].toString())
          : map['appointment_date'] != null 
              ? DateTime.parse(map['appointment_date'].toString())
              : DateTime.fromMillisecondsSinceEpoch(map['endTime'] ?? 0),
      notes: map['notes'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => AppointmentStatus.pending,
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
      'appointment_date': startTime.toIso8601String().split('T')[0],
      'customer_name': customerName,
      'tailor_name': tailorName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'notes': notes,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? tailorId,
    String? tailorName,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    AppointmentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      tailorId: tailorId ?? this.tailorId,
      tailorName: tailorName ?? this.tailorName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
