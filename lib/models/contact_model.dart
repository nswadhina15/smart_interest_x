class ContactModel {
  String? id;
  String userId;
  String name;
  String phoneNumber;
  String type;

  ContactModel({
    this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.type,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ContactModel(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      type: map['type'] ?? 'Borrower',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'type': type,
    };
  }
}
