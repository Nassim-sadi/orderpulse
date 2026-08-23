import 'package:flutter/material.dart';

import '../../domain/entities/order_entity.dart';

class OrderStatusVisuals {
  const OrderStatusVisuals(this.color, this.label);

  final Color color;
  final String label;
}

OrderStatusVisuals statusVisuals(OrderStatus status) => switch (status) {
      OrderStatus.pending =>
        const OrderStatusVisuals(Color(0xFF8D99AE), 'PENDING'),
      OrderStatus.confirmed =>
        const OrderStatusVisuals(Color(0xFF6C8EEF), 'CONFIRMED'),
      OrderStatus.dispatched =>
        const OrderStatusVisuals(Color(0xFF9B7EDE), 'DISPATCHED'),
      OrderStatus.outForDelivery =>
        const OrderStatusVisuals(Color(0xFF4F7DF9), 'OUT FOR DELIVERY'),
      OrderStatus.deliveredPaid =>
        const OrderStatusVisuals(Color(0xFF2FD07A), 'DELIVERED & PAID'),
      OrderStatus.failedPendingVerification =>
        const OrderStatusVisuals(Color(0xFFF5B942), 'PENDING VERIFICATION'),
      OrderStatus.returned =>
        const OrderStatusVisuals(Color(0xFFF4553E), 'RETURNED'),
    };

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final visuals = statusVisuals(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: visuals.color.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: visuals.color),
      ),
      child: Text(
        visuals.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
          color: visuals.color,
        ),
      ),
    );
  }
}
