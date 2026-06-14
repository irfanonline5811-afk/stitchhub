/// Manual Payment Model for StitchHub App
/// Represents manual payments submitted via JazzCash/EasyPaisa
class ManualPaymentModel {
  final String id;
  final String orderId;
  final String customerName;
  final String customerPhone;
  final double amount;
  final String paymentMethod; // 'jazzcash', 'easypaisa', 'cod'
  final String? transactionId; // TID entered by user
  final String? screenshotUrl; // Proof receipt image url in Supabase storage
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  ManualPaymentModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.screenshotUrl,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory ManualPaymentModel.fromMap(Map<String, dynamic> map) {
    return ManualPaymentModel(
      id: map['id'] ?? '',
      orderId: map['order_id'] ?? '',
      customerName: map['customer_name'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentMethod: map['payment_method'] ?? '',
      transactionId: map['transaction_id'],
      screenshotUrl: map['screenshot_url'],
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'screenshot_url': screenshotUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ManualPaymentModel copyWith({
    String? id,
    String? orderId,
    String? customerName,
    String? customerPhone,
    double? amount,
    String? paymentMethod,
    String? transactionId,
    String? screenshotUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManualPaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
