import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../../backend/services/receipt_ocr_service.dart';
import '../../../backend/models/receipt.dart';
import '../../../backend/services/expense_tracking_service.dart';
import '../../../backend/models/expense_tracking.dart';

// Figma Design Colors
const Color kExpenseRed = Color(0xFFE85D5D);
const Color kExpenseWhite = Color(0xFFFFFFFF);
const Color kExpenseBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kInputBg = Color(0xFFF9FAFB);
const Color kInputBorder = Color(0xFFE5E7EB);

class ReceiptUploadScreen extends StatefulWidget {
  const ReceiptUploadScreen({super.key});

  @override
  State<ReceiptUploadScreen> createState() => _ReceiptUploadScreenState();
}

class _ReceiptUploadScreenState extends State<ReceiptUploadScreen> {
  final ReceiptOcrService _ocrService = ReceiptOcrService();
  final ExpenseTrackingService _expenseService = ExpenseTrackingService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _activeTab = true; // true = scan, false = manual
  File? _selectedImage;
  bool _isProcessing = false;
  DateTime? _selectedDate;
  Receipt? _processedReceipt;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _totalAmountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kExpenseBackground,
      appBar: AppBar(
        backgroundColor: kExpenseWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Receipt',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // Tab Switcher
              _buildTabSwitcher(),
              const SizedBox(height: 16),

              // Content based on active tab
              if (_activeTab) _buildScanTab() else _buildManualTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Scan Receipt', true)),
          Expanded(child: _buildTabButton('Manual Entry', false)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isScan) {
    final isActive = _activeTab == isScan;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = isScan),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: isActive ? kExpenseRed : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: kExpenseRed.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? kExpenseWhite : kTextLight,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _buildScanTab() {
    return Column(
      children: [
        // Receipt Upload Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kExpenseWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: kExpenseRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Upload E-Receipt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextDark,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedImage == null) ...[
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: kInputBorder,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.upload, size: 32, color: kTextLight),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload Receipt',
                          style: TextStyle(
                            color: kTextLight,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to select image',
                          style: TextStyle(
                            color: kTextLight.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kInputBg,
                          foregroundColor: kTextDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          _selectedImage = null;
                          _processedReceipt = null;
                        }),
      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: kExpenseWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Remove',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isProcessing) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Processing receipt...',
                      style: TextStyle(
                        color: kTextLight,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
                if (_processedReceipt != null && !_isProcessing) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kInputBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detected Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Store:', _processedReceipt!.storeName),
                        _buildInfoRow(
                          'Total Amount:', 
                          'MYR ${_processedReceipt!.totalAmount.toStringAsFixed(2)}', 
                          isAmount: true,
                        ),
                        _buildInfoRow(
                          'Date:', 
                          '${_processedReceipt!.purchaseDate.day}/${_processedReceipt!.purchaseDate.month}/${_processedReceipt!.purchaseDate.year}',
                        ),
                        _buildInfoRow('Items:', '${_processedReceipt!.items.length} items'),
                        const SizedBox(height: 12),
                        Text(
                          'Review and edit the detected information before saving',
                          style: TextStyle(
                            color: kTextLight,
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Form Fields (shown when image is selected)
        if (_selectedImage != null) _buildFormFields(),
        const SizedBox(height: 16),
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_selectedImage != null || _storeNameController.text.isNotEmpty) && !_isProcessing
                ? _handleSubmit
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kExpenseRed,
              foregroundColor: kExpenseWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              _selectedImage != null
                  ? 'Save Receipt'
                  : 'Upload a Receipt to Continue',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Expense Details Form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kExpenseWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                // Amount
                _buildFormField(
                  label: 'Amount *',
                  icon: Icons.attach_money,
                  controller: _totalAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Store
                _buildFormField(
                  label: 'Store Name *',
                  icon: Icons.store,
                  controller: _storeNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a store name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Date
                _buildFormField(
                  label: 'Date *',
                  icon: Icons.calendar_today,
                  controller: _dateController,
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                        _dateController.text = date.toString().split(' ')[0];
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Notes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kTextDark,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
      decoration: InputDecoration(
                        hintText: 'Add any additional notes...',
                        hintStyle: const TextStyle(color: kTextLight),
        filled: true,
                        fillColor: kInputBg,
        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kInputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kInputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: kExpenseRed,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kInputBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: kTextDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kExpenseRed,
                    foregroundColor: kExpenseWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              kExpenseWhite,
                            ),
                          ),
                        )
                      : const Text(
                          'Save Expense',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kExpenseWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextDark,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 20),
          // Store Name
          _buildFormField(
            label: 'Store Name *',
            icon: Icons.store,
            controller: _storeNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a store name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Amount
          _buildFormField(
            label: 'Total Amount *',
            icon: Icons.attach_money,
            controller: _totalAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Date
          _buildFormField(
            label: 'Date *',
            icon: Icons.calendar_today,
            controller: _dateController,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
              context: context,
                initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _dateController.text = date.toString().split(' ')[0];
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: kTextLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kTextDark,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            hintText: label.contains('Amount') ? '0.00' : 'Enter ${label.toLowerCase().replaceAll('*', '').trim()}',
            hintStyle: const TextStyle(color: kTextLight),
            filled: true,
            fillColor: kInputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: kExpenseRed,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kTextLight,
              fontSize: 14,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isAmount ? kExpenseRed : kTextDark,
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isProcessing = true;
          _processedReceipt = null;
        });

        // Process the receipt
        await _processReceipt(image);
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processReceipt(XFile imageFile) async {
    try {
      setState(() => _isProcessing = true);

      // Extract receipt data (without saving)
      final receiptData = await _ocrService.extractReceiptData(
        imageFile: imageFile,
        storeName: _storeNameController.text.isNotEmpty ? _storeNameController.text : null,
        purchaseDate: _selectedDate,
      );

      // Convert to Receipt object for display
      final receipt = Receipt(
        id: '',
        userId: '',
        storeId: '',
        storeName: receiptData['storeName'] as String,
        imageUrl: '',
        totalAmount: receiptData['totalAmount'] as double,
        currency: 'MYR',
        purchaseDate: receiptData['purchaseDate'] as DateTime,
        items: (receiptData['items'] as List<dynamic>).map((item) {
          return ReceiptItem(
            productName: item['productName'] as String,
            price: item['price'] as double,
            quantity: item['quantity'] as int? ?? 1,
            category: item['category'] as String?,
          );
        }).toList(),
        status: 'pending',
        ocrText: receiptData['ocrText'] as String,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _processedReceipt = receipt;
        _isProcessing = false;
        
        // Auto-fill form fields from OCR results
        if (_storeNameController.text.isEmpty && receipt.storeName != 'Unknown Store') {
          _storeNameController.text = receipt.storeName;
        }
        if (_totalAmountController.text.isEmpty && receipt.totalAmount > 0) {
          _totalAmountController.text = receipt.totalAmount.toStringAsFixed(2);
        }
        if (_selectedDate == null) {
          _selectedDate = receipt.purchaseDate;
          _dateController.text = receipt.purchaseDate.toString().split(' ')[0];
        }
      });

      if (mounted) {
        if (receipt.items.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Receipt scanned! Found ${receipt.items.length} items. Review and click Save.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📝 Receipt image ready. Please enter details manually and click Save.'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing receipt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing receipt: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save receipts'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!_activeTab && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final expenseDate = _selectedDate ?? DateTime.now();
      final amount = double.tryParse(_totalAmountController.text) ?? 0.0;

      if (amount <= 0) {
        throw Exception('Please enter a valid amount');
      }

      // If we have an image, process it with manual data
      if (_selectedImage != null && _activeTab) {
        // Convert File to XFile
        final xFile = XFile(_selectedImage!.path);
        
        // Process receipt (this will save it to Firebase)
        final receipt = await _ocrService.processReceipt(
          imageFile: xFile,
          userId: user.uid,
          storeName: _storeNameController.text.isNotEmpty 
              ? _storeNameController.text 
              : 'Unknown Store',
          purchaseDate: expenseDate,
        );

        // Create expense entry
        final expense = ExpenseTracking(
          id: '',
          userId: user.uid,
          amount: amount,
          currency: 'MYR',
          description: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : 'Receipt from ${_storeNameController.text.trim()}',
          date: expenseDate,
          storeName: _storeNameController.text.trim(),
          category: 'Groceries',
          tags: ['receipt'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _expenseService.addExpense(expense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Receipt saved successfully! ${receipt.items.length} items found.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Navigate back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        // Manual entry - create expense directly
        final expense = ExpenseTracking(
          id: '',
          userId: user.uid,
          amount: amount,
          currency: 'MYR',
          description: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : 'Expense at ${_storeNameController.text.trim()}',
          date: expenseDate,
          storeName: _storeNameController.text.trim(),
          category: 'Groceries',
          tags: ['manual'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _expenseService.addExpense(expense);

        if (mounted) {
          setState(() => _isProcessing = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Expense of MYR ${expense.amount.toStringAsFixed(2)} saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving expense: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
