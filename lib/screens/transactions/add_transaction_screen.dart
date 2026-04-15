import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/database_service.dart';
import '../../models/transaction_model.dart';
import '../../models/contact_model.dart';
import 'package:lottie/lottie.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _amountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _notesController = TextEditingController();

  // State Variables
  String _transactionType = 'Given';
  DateTime _startDate = DateTime.now();
  DateTime? _dueDate;
  File? _selectedImage;
  String? _selectedContactId;

  // Image Picker Logic
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Date Picker Logic
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_dueDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A8A)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/success.json',
                  width: 200,
                  height: 200,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Loan Recorded!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("The transaction has been saved to Firebase."),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Loan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _transactionType = 'Given'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _transactionType == 'Given'
                                ? const Color(0xFF1E3A8A)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(11),
                            ),
                          ),
                          child: Text(
                            'I Gave (Lent)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _transactionType == 'Given'
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _transactionType = 'Taken'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _transactionType == 'Taken'
                                ? const Color(0xFF1E3A8A)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(11),
                            ),
                          ),
                          child: Text(
                            'I Took (Borrowed)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _transactionType == 'Taken'
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              StreamBuilder<List<ContactModel>>(
                stream: DatabaseService().getUserContacts(
                  context.read<AuthService>().getCurrentUser()?.uid ?? '',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: LinearProgressIndicator(color: Color(0xFF1E3A8A)),
                    );
                  }

                  final contacts = snapshot.data ?? [];

                  if (contacts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Text(
                        'Please add a contact from the Contacts Screen before creating a loan.',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedContactId,
                    decoration: _buildInputDecoration(
                      'Select Borrower / Lender',
                      Icons.person_outline,
                    ),
                    items: contacts.map((contact) {
                      return DropdownMenuItem<String>(
                        value: contact.id,
                        child: Text("${contact.name} (${contact.type})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedContactId = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a contact' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                  'Principal Amount (₹)',
                  Icons.currency_rupee,
                ),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 16),

              // Interest Rate Field
              TextFormField(
                controller: _interestRateController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                  'Interest Rate (% per month)',
                  Icons.percent,
                ),
                validator: (value) => value!.isEmpty ? 'Enter rate' : null,
              ),
              const SizedBox(height: 24),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: _buildDateCard(
                        'Start Date',
                        "${_startDate.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: _buildDateCard(
                        'Due Date',
                        _dueDate == null
                            ? 'Select Date'
                            : "${_dueDate!.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Image Upload Section
              const Text(
                'Payment Proof (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload receipt',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            String? imageUrl;

                            // 1. Upload Image to Cloudinary (if selected)
                            if (_selectedImage != null) {
                              final cloudinary = CloudinaryService();
                              imageUrl = await cloudinary.uploadImage(
                                _selectedImage!,
                              );

                              if (imageUrl == null) {
                                throw Exception("Failed to upload image.");
                              }
                            }

                            // 2. Get the logged-in user's ID
                            final currentUser = context
                                .read<AuthService>()
                                .getCurrentUser();
                            if (currentUser == null)
                              throw Exception("User not logged in.");

                            // 3. Build the Transaction Model
                            final newTransaction = TransactionModel(
                              userId: currentUser.uid,
                              contactId: _selectedContactId!,
                              amount: double.parse(_amountController.text),
                              type: _transactionType,
                              interestRate: double.parse(
                                _interestRateController.text,
                              ),
                              startDate: _startDate,
                              dueDate: _dueDate,
                              notes: "Added from app",
                              paymentProofUrl: imageUrl,
                              isSettled: false,
                            );

                            // 4. Save to Firestore
                            final dbService = DatabaseService();
                            await dbService.addTransaction(newTransaction);

                            // 5. Success! Close the screen
                            if (mounted) {
                              setState(() => _isLoading = false);
                              _showSuccessDialog();
                            }
                          } catch (e) {
                            // Handle Errors
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable UI Helpers
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
    );
  }

  Widget _buildDateCard(String title, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
