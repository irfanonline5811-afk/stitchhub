class OfflineAction {
  final String id;
  final String actionType;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  OfflineAction({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.createdAt,
  });

  factory OfflineAction.fromMap(Map<String, dynamic> map) {
    return OfflineAction(
      id: map['id'] ?? '',
      actionType: map['actionType'] ?? '',
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionType': actionType,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
