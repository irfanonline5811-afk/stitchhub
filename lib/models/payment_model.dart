enum PaymentTransactionStatus {
  pending,
  processing,
  succeeded,
  failed,
  cancelled,
  refunded,
}

class PaymentModel {
  final String id;
  final String orderId;
  final String customerId;
  final String? transactionId; // Wallet Transaction ID (TID)
  final String? paymentMethod; // e.g., 'jazzcash', 'easypaisa', 'cash'
  final double amount;
  final String currency;
  final PaymentTransactionStatus status;
  final String? failureReason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    this.transactionId,
    this.paymentMethod,
    required this.amount,
    this.currency = 'pkr',
    this.status = PaymentTransactionStatus.pending,
    this.failureReason,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      orderId: map['order_id'] ?? map['orderId'] ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      transactionId: map['transaction_id'] ?? map['transactionId'],
      paymentMethod: map['payment_method'] ?? map['paymentMethod'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'pkr',
      status: PaymentTransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PaymentTransactionStatus.pending,
      ),
      failureReason: map['failure_reason'] ?? map['failureReason'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
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
      'order_id': orderId,
      'customer_id': customerId,
      'transaction_id': transactionId,
      'payment_method': paymentMethod,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'failure_reason': failureReason,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? transactionId,
    String? paymentMethod,
    double? amount,
    String? currency,
    PaymentTransactionStatus? status,
    String? failureReason,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
