class ReviewModel {
  final String id;
  final String orderId;
  final String customerId;
  final String tailorId;
  final String customerName;
  final String? customerImageUrl;
  final double rating; // 1 to 5
  final String comment;
  final List<String> images;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.tailorId,
    required this.customerName,
    this.customerImageUrl,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      orderId: map['order_id'] ?? map['orderId'] ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      tailorId: map['tailor_id'] ?? map['tailorId'] ?? '',
      customerName: map['customer_name'] ?? map['customerName'] ?? '',
      customerImageUrl: map['customer_image_url'] ?? map['customerImageUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_id': customerId,
      'tailor_id': tailorId,
      'customer_name': customerName,
      'customer_image_url': customerImageUrl,
      'rating': rating,
      'comment': comment,
      'images': images,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
