import 'package:flutter/material.dart';

// Figma Design Colors
const Color kPaymentRed = Color(0xFFE85D5D);
const Color kPaymentWhite = Color(0xFFFFFFFF);
const Color kPaymentBackground = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextLight = Color(0xFF808080);
const Color kCardBg = Color(0xFFFFFFFF);
const Color kBorderGray = Color(0xFFE5E7EB);

// Payment Method Model
class PaymentMethod {
  final String id;
  final String type; // 'card', 'bank', 'ewallet'
  final String name;
  final String? last4;
  final String? expiryDate;
  final bool isDefault;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.last4,
    this.expiryDate,
    this.isDefault = false,
    required this.icon,
  });
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'card',
      name: 'Visa',
      last4: '4242',
      expiryDate: '12/25',
      isDefault: true,
      icon: Icons.credit_card,
    ),
    PaymentMethod(
      id: '2',
      type: 'ewallet',
      name: 'Touch \'n Go eWallet',
      isDefault: false,
      icon: Icons.account_balance_wallet,
    ),
    PaymentMethod(
      id: '3',
      type: 'bank',
      name: 'Maybank',
      last4: '1234',
      isDefault: false,
      icon: Icons.account_balance,
    ),
  ];

  void _setAsDefault(String id) {
    setState(() {
      _paymentMethods = _paymentMethods.map((method) {
        return PaymentMethod(
          id: method.id,
          type: method.type,
          name: method.name,
          last4: method.last4,
          expiryDate: method.expiryDate,
          isDefault: method.id == id,
          icon: method.icon,
        );
      }).toList();
    });
  }

  void _deletePaymentMethod(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((method) => method.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPaymentBackground,
      appBar: AppBar(
        backgroundColor: kPaymentWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: kTextDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kPaymentRed),
            onPressed: () {
              // TODO: Add new payment method
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add payment method feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_paymentMethods.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.credit_card_off, size: 64, color: kTextLight),
                        const SizedBox(height: 16),
                        const Text(
                          'No payment methods',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kTextDark,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a payment method to get started',
                          style: TextStyle(
                            color: kTextLight,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._paymentMethods.map((method) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kCardBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kPaymentRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            method.icon,
                            color: kPaymentRed,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    method.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kTextDark,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  if (method.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPaymentRed,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Default',
                                        style: TextStyle(
                                          color: kPaymentWhite,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (method.last4 != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '**** **** **** ${method.last4}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kTextLight,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                              if (method.expiryDate != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Expires ${method.expiryDate}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kTextLight,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: kTextLight),
                          itemBuilder: (context) => [
                            if (!method.isDefault)
                              PopupMenuItem(
                                child: const Text('Set as Default'),
                                onTap: () => _setAsDefault(method.id),
                              ),
                            PopupMenuItem(
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              onTap: () => _deletePaymentMethod(method.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}

