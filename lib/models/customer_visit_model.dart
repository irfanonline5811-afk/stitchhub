class CustomerVisitModel {
  final String id;
  final String customerId;
  final String tailorId;
  final String customerName;
  final String tailorName;
  final String customerPhone;
  final String? customerEmail;
  final String? customerAddress;
  final String? notes;
  final DateTime visitDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerVisitModel({
    required this.id,
    required this.customerId,
    required this.tailorId,
    required this.customerName,
    required this.tailorName,
    required this.customerPhone,
    this.customerEmail,
    this.customerAddress,
    this.notes,
    required this.visitDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerVisitModel.fromMap(Map<String, dynamic> map) {
    return CustomerVisitModel(
      id: map['id'] ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      tailorId: map['tailor_id'] ?? map['tailorId'] ?? '',
      customerName: map['customer_name'] ?? map['customerName'] ?? '',
      tailorName: map['tailor_name'] ?? map['tailorName'] ?? '',
      customerPhone: map['customer_phone'] ?? map['customerPhone'] ?? '',
      customerEmail: map['customer_email'] ?? map['customerEmail'],
      customerAddress: map['customer_address'] ?? map['customerAddress'],
      notes: map['notes'],
      visitDate: map['visit_date'] != null 
          ? DateTime.parse(map['visit_date'].toString())
          : DateTime.fromMillisecondsSinceEpoch(map['visitDate'] ?? 0),
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
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'customer_address': customerAddress,
      'notes': notes,
      'visit_date': visitDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CustomerVisitModel copyWith({
    String? id,
    String? customerId,
    String? tailorId,
    String? customerName,
    String? tailorName,
    String? customerPhone,
    String? customerEmail,
    String? customerAddress,
    String? notes,
    DateTime? visitDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerVisitModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      tailorId: tailorId ?? this.tailorId,
      customerName: customerName ?? this.customerName,
      tailorName: tailorName ?? this.tailorName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      customerAddress: customerAddress ?? this.customerAddress,
      notes: notes ?? this.notes,
      visitDate: visitDate ?? this.visitDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
