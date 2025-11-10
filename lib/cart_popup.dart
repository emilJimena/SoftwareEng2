import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';

class CartPopupPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onClose;

  const CartPopupPage({
    Key? key,
    required this.cartItems,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CartPopupPage> createState() => _CartPopupPageState();
}

class _CartPopupPageState extends State<CartPopupPage> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    items = widget.cartItems.map((item) {
      int qty = 1;
      if (item['quantity'] is int) {
        qty = item['quantity'];
      } else if (item['quantity'] is String) {
        qty = int.tryParse(item['quantity']) ?? 1;
      }
      return {...item, 'quantity': qty};
    }).toList();
  }

  void _incrementQuantity(int index) {
    setState(() {
      items[index]['quantity'] += 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (items[index]['quantity'] > 1) items[index]['quantity'] -= 1;
    });
  }

  double _computeItemTotal(Map<String, dynamic> item) {
    double basePrice = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
    double addonsTotal = 0;

    if (item['addons'] != null) {
      for (var addon in item['addons']) {
        if (addon is Map<String, dynamic>) {
          addonsTotal +=
              double.tryParse(addon['price']?.toString() ?? '0') ?? 0;
        }
      }
    }

    int quantity = 1;
    if (item['quantity'] is int) {
      quantity = item['quantity'];
    } else if (item['quantity'] is String) {
      quantity = int.tryParse(item['quantity']) ?? 1;
    }

    return (basePrice + addonsTotal) * quantity;
  }

  double get _cartTotal {
    return items.fold(0.0, (sum, item) => sum + _computeItemTotal(item));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width * 0.35,
        color: const Color(0xFF2C2C2C),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.orangeAccent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Cart",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Cart Items List
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        "Cart is empty",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          color: Colors.grey[850],
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? 'Unnamed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (item['addons'] != null &&
                                    (item['addons'] as List).isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Addons:",
                                        style: GoogleFonts.poppins(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      ...List.generate(
                                        (item['addons'] as List).length,
                                        (addonIndex) {
                                          final addon =
                                              item['addons'][addonIndex];
                                          String addonName = '';
                                          double addonPrice = 0;
                                          if (addon is Map<String, dynamic>) {
                                            addonName = addon['name'] ?? '';
                                            addonPrice =
                                                double.tryParse(
                                                  addon['price']?.toString() ??
                                                      '0',
                                                ) ??
                                                0;
                                          }
                                          return Text(
                                            addonPrice > 0
                                                ? "$addonName (+₱${addonPrice.toStringAsFixed(2)})"
                                                : addonName,
                                            style: GoogleFonts.poppins(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _decrementQuantity(index),
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.orangeAccent,
                                          ),
                                        ),
                                        Text(
                                          item['quantity'].toString(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _incrementQuantity(index),
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.orangeAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "₱${_computeItemTotal(item).toStringAsFixed(2)}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Total & Checkout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[900]),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total:",
                        style: GoogleFonts.poppins(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "₱${_cartTotal.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Cart is empty")),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.orangeAccent,
                            ),
                          ),
                        );

                        final apiBase = await ApiConfig.getBaseUrl();
                        bool success = true;

                        try {
                          for (var item in items) {
                            final menuId =
                                int.tryParse(
                                  item['menu_id']?.toString() ?? '0',
                                ) ??
                                0;
                            final quantity =
                                int.tryParse(
                                  item['quantity']?.toString() ?? '1',
                                ) ??
                                1;
                            if (menuId <= 0) continue;

                            List<int> addonIds = [];
                            if (item['addons'] != null &&
                                item['addons'] is List) {
                              for (var addon in item['addons']) {
                                if (addon is Map<String, dynamic> &&
                                    addon['id'] != null) {
                                  addonIds.add(addon['id']);
                                }
                              }
                            }

                            final response = await http
                                .post(
                                  Uri.parse(
                                    '$apiBase/inventory/deduct_inventory.php',
                                  ),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'menu_id': menuId,
                                    'quantity': quantity,
                                    'selected_addon_ids': addonIds,
                                  }),
                                )
                                .timeout(const Duration(seconds: 10));

                            if (response.statusCode != 200) {
                              throw Exception(
                                'Server error: ${response.statusCode}',
                              );
                            }

                            final data = jsonDecode(response.body);
                            final deductions =
                                data['deductions'] as Map<String, dynamic>?;

                            if (data['success'] != true ||
                                deductions == null ||
                                deductions.isEmpty) {
                              throw Exception(
                                data['message'] ??
                                    'No materials were deducted for this item.',
                              );
                            }
                          }

                          setState(() {
                            items.clear();
                          });
                        } catch (e) {
                          success = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Checkout failed: $e')),
                          );
                        } finally {
                          Navigator.pop(context); // Remove spinner
                        }

                        if (success) {
                          setState(() {
                            items.clear();
                          });
                          widget.cartItems.clear(); // ✅ also clear parent cart
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Checkout successful! Materials deducted.',
                              ),
                            ),
                          );
                          widget.onClose();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Checkout",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
