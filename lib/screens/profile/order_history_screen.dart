import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../cart/cart_and_checkout.dart' show OrderModel, OrderService;
import '../theme/app_theme.dart';

/// Past simulated orders for the signed-in fan, newest first.
///
/// Orders are already saved by [OrderService.placeOrder] (top-level
/// `orders` collection, one document per completed checkout) when the fan
/// completes the simulated checkout in the cart. This screen only reads
/// them back; it does not change the checkout flow.
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = OrderService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder<List<OrderModel>>(
        stream: service.streamMyOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your orders: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          final orders = snapshot.data ?? const <OrderModel>[];

          if (orders.isEmpty) {
            return const _EmptyOrders();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderTile(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, size: 52, color: AppColors.textMuted),
            SizedBox(height: 14),
            Text(
              'No orders yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Items you check out from your cart will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatefulWidget {
  const _OrderTile({required this.order});

  final OrderModel order;

  @override
  State<_OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<_OrderTile> {
  bool _expanded = false;

  String _money(double v, String currency) {
    final symbol = currency == 'USD' ? '\$' : '$currency ';
    return '$symbol${v.toStringAsFixed(2)}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.gold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final itemCount =
        order.items.fold<int>(0, (sum, i) => sum + ((i['quantity'] ?? 0) as num).toInt());
    final date = order.createdAt?.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.card(),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: AppColors.primaryLight,
                size: 21,
              ),
            ),
            title: Text(
              'Order #${order.id.substring(0, order.id.length.clamp(0, 8))}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
            subtitle: Text(
              [
                if (date != null) DateFormat('d MMM yyyy, h:mm a').format(date),
                '$itemCount item${itemCount == 1 ? '' : 's'}',
              ].join(' · '),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(order.totalAmount, order.currency),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name'] ?? 'Item'} × ${item['quantity'] ?? 1}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Text(
                            _money(
                              ((item['price'] ?? 0) as num).toDouble() *
                                  ((item['quantity'] ?? 1) as num).toInt(),
                              (item['currency'] ?? order.currency).toString(),
                            ),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (order.shippingAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Shipping to: ${order.shippingAddress}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
