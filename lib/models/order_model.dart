enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  cutting,
  stitching,
  qualityCheck,
  readyForPickup,
  completed,
  cancelled,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum PaymentMethod {
  cashOnDelivery,
  wallet,
}

class OrderModel {
  final String id;
  final String customerId;
  final String tailorId;
  final String customerName;
  final String tailorName;
  final String serviceType; // 'shirt', 'pants', 'dress', etc.
  final String description;
  final List<String> images; // images of the item to be stitched
  final Map<String, dynamic> measurements; // custom measurements
  final double price;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final DateTime orderDate;
  final DateTime? confirmedDate;
  final DateTime? completedDate;
  final DateTime? pickupDate;
  final DateTime? deliveryDate;
  final DateTime? estimatedDeliveryDate;
  final String? notes;
  final String? customerAddress;
  final String? tailorAddress;
  final double? currentLatitude;
  final double? currentLongitude;
  final String? currentLocationName;
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.tailorId,
    required this.customerName,
    required this.tailorName,
    required this.serviceType,
    required this.description,
    this.images = const [],
    this.measurements = const {},
    required this.price,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod = PaymentMethod.cashOnDelivery,
    required this.orderDate,
    this.confirmedDate,
    this.completedDate,
    this.pickupDate,
    this.deliveryDate,
    this.estimatedDeliveryDate,
    this.notes,
    this.customerAddress,
    this.tailorAddress,
    this.currentLatitude,
    this.currentLongitude,
    this.currentLocationName,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      tailorId: map['tailor_id'] ?? map['tailorId'] ?? '',
      customerName: map['customer_name'] ?? map['customerName'] ?? '',
      tailorName: map['tailor_name'] ?? map['tailorName'] ?? '',
      serviceType: map['service_type'] ?? map['serviceType'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      measurements: Map<String, dynamic>.from(map['measurements'] ?? {}),
      price: (map['price'] ?? map['total_amount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['payment_status'] ?? map['paymentStatus']),
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == (map['payment_method'] ?? map['paymentMethod']),
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      orderDate: map['order_date'] != null 
          ? DateTime.parse(map['order_date'].toString())
          : DateTime.fromMillisecondsSinceEpoch(map['orderDate'] ?? 0),
      confirmedDate: map['confirmed_date'] != null
          ? DateTime.parse(map['confirmed_date'].toString())
          : map['confirmedDate'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(map['confirmedDate'])
            : null,
      completedDate: map['completed_date'] != null
          ? DateTime.parse(map['completed_date'].toString())
          : map['completedDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['completedDate'])
            : null,
      pickupDate: map['pickup_date'] != null
          ? DateTime.parse(map['pickup_date'].toString())
          : map['pickupDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['pickupDate'])
            : null,
      deliveryDate: map['delivery_date'] != null
          ? DateTime.parse(map['delivery_date'].toString())
          : map['deliveryDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['deliveryDate'])
            : null,
      estimatedDeliveryDate: map['estimated_delivery_date'] != null
          ? DateTime.parse(map['estimated_delivery_date'].toString())
          : map['estimatedDeliveryDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['estimatedDeliveryDate'])
            : null,
      notes: map['notes'],
      customerAddress: map['customer_address'] ?? map['customerAddress'],
      tailorAddress: map['tailor_address'] ?? map['tailorAddress'],
      currentLatitude: (map['current_latitude'] ?? map['currentLatitude'])?.toDouble(),
      currentLongitude: (map['current_longitude'] ?? map['currentLongitude'])?.toDouble(),
      currentLocationName: map['current_location_name'] ?? map['currentLocationName'],
      rating: map['rating']?.toDouble(),
      review: map['review'],
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
      'service_type': serviceType,
      'description': description,
      'images': images,
      'measurements': measurements,
      'price': price,
      'total_amount': price,
      'status': status.toString().split('.').last,
      'payment_status': paymentStatus.toString().split('.').last,
      'payment_method': paymentMethod.toString().split('.').last,
      'order_date': orderDate.toIso8601String(),
      'confirmed_date': confirmedDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'pickup_date': pickupDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
      'notes': notes,
      'customer_address': customerAddress,
      'tailor_address': tailorAddress,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'current_location_name': currentLocationName,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? tailorId,
    String? customerName,
    String? tailorName,
    String? serviceType,
    String? description,
    List<String>? images,
    Map<String, dynamic>? measurements,
    double? price,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    DateTime? orderDate,
    DateTime? confirmedDate,
    DateTime? completedDate,
    DateTime? pickupDate,
    DateTime? deliveryDate,
    DateTime? estimatedDeliveryDate,
    String? notes,
    String? customerAddress,
    String? tailorAddress,
    double? currentLatitude,
    double? currentLongitude,
    String? currentLocationName,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      tailorId: tailorId ?? this.tailorId,
      customerName: customerName ?? this.customerName,
      tailorName: tailorName ?? this.tailorName,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      images: images ?? this.images,
      measurements: measurements ?? this.measurements,
      price: price ?? this.price,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderDate: orderDate ?? this.orderDate,
      confirmedDate: confirmedDate ?? this.confirmedDate,
      completedDate: completedDate ?? this.completedDate,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      notes: notes ?? this.notes,
      customerAddress: customerAddress ?? this.customerAddress,
      tailorAddress: tailorAddress ?? this.tailorAddress,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      currentLocationName: currentLocationName ?? this.currentLocationName,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
