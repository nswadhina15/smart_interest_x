class TransactionModel {
  String? id;
  String userId;
  String contactId;
  double amount;
  String type;
  double interestRate;
  DateTime startDate;
  DateTime? dueDate;
  String notes;
  String? paymentProofUrl;
  bool isSettled;

  TransactionModel({
    this.id,
    required this.userId,
    required this.contactId,
    required this.amount,
    required this.type,
    required this.interestRate,
    required this.startDate,
    this.dueDate,
    this.notes = '',
    this.paymentProofUrl,
    this.isSettled = false,
  });

  // 1. Reading FROM Firebase (Map to Object)
  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      contactId: map['contactId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'Given',
      interestRate: (map['interestRate'] ?? 0).toDouble(),
      startDate: DateTime.parse(map['startDate']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      notes: map['notes'] ?? '',
      paymentProofUrl: map['paymentProofUrl'],
      isSettled: map['isSettled'] ?? false,
    );
  }

  // 2. Writing TO Firebase (Object to Map)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'contactId': contactId,
      'amount': amount,
      'type': type,
      'interestRate': interestRate,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'paymentProofUrl': paymentProofUrl,
      'isSettled': isSettled,
    };
  }
}
