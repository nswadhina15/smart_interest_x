import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/contact_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _db.collection('transactions').add(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to save transaction: $e');
    }
  }

  Stream<List<TransactionModel>> getUserTransactions(String userId) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TransactionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Add a new contact
  Future<void> addContact(ContactModel contact) async {
    try {
      await _db.collection('contacts').add(contact.toMap());
      print("Contact added successfully!");
    } catch (e) {
      print("Error adding contact: $e");
      throw Exception('Failed to save contact: $e');
    }
  }

  Stream<List<ContactModel>> getUserContacts(String userId) {
    return _db
        .collection('contacts')
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ContactModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
