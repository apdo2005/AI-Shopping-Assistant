import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/order_entity.dart';
import '../bloc/orders_cubit.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final OrderEntity initial;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.initial,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Future<OrderEntity?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<OrdersCubit>().details(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf9ff),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text('Order Details', style: _font(17, FontWeight.w700)),
      ),
      body: FutureBuilder<OrderEntity?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data ?? widget.initial;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = context.read<OrdersCubit>().details(widget.orderId);
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Status(order),
                const SizedBox(height: 12),
                _Timeline(order),
                const SizedBox(height: 12),
                _Items(order),
                const SizedBox(height: 12),
                _Summary(order),
                const SizedBox(height: 12),
                _Delivery(order),
                if ((order.notes ?? '').isNotEmpty ||
                    (order.specialNote ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _Notes(order),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final OrderEntity order;

  const _Status(this.order);

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _box(),
      child: Row(
        children: [
          Icon(_statusIcon(order.status), color: color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pretty(order.status), style: _font(16, FontWeight.w700)),
                if (order.statusDescription.isNotEmpty)
                  Text(
                    order.statusDescription,
                    style: _font(
                      11.5,
                      FontWeight.w400,
                      const Color(0xff89859c),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            order.number.isEmpty ? 'Order' : '#${order.number}',
            style: _font(11, FontWeight.w600, const Color(0xff6251d7)),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final OrderEntity order;

  const _Timeline(this.order);

  @override
  Widget build(BuildContext context) {
    final events = [
      ('Order placed', order.placedAt ?? order.createdAt),
      ('Processing', order.processingAt),
      ('Shipped', order.shippingAt),
      ('Out for delivery', order.outForDeliveryAt),
      ('Delivered', order.deliveredAt),
    ];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order progress', style: _font(14, FontWeight.w700)),
          const SizedBox(height: 12),
          ...events.asMap().entries.map((entry) {
            final done =
                entry.value.$2?.isNotEmpty == true ||
                order.statusPosition > entry.key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 17,
                    color: done
                        ? const Color(0xff6251d7)
                        : const Color(0xffc3bfd0),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      entry.value.$1,
                      style: _font(
                        12,
                        done ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    _date(entry.value.$2),
                    style: _font(10, FontWeight.w400, const Color(0xff89859c)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Items extends StatelessWidget {
  final OrderEntity order;

  const _Items(this.order);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: _font(14, FontWeight.w700)),
          const SizedBox(height: 9),
          if (order.items.isEmpty)
            Text(
              'Item details are unavailable for this order.',
              style: _font(12, FontWeight.w400, const Color(0xff89859c)),
            )
          else
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xfff0edfa),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: item.imageUrl.isEmpty
                          ? const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xff6251d7),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                    ? child
                                    : const ColoredBox(
                                        color: Color(0xfff0edfa),
                                        child: Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                errorBuilder: (_, __, ___) {
                                  return const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Color(0xff6251d7),
                                  );
                                },
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name.isEmpty
                                ? 'Product unavailable'
                                : item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _font(12, FontWeight.w600),
                          ),
                          if (_itemDetail(item).isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              _itemDetail(item),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _font(
                                10.5,
                                FontWeight.w400,
                                const Color(0xff89859c),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '${item.quantity} × ${_money(item.unitPrice)}\n'
                      '${_money(item.subtotal)}',
                      textAlign: TextAlign.end,
                      style: _font(10.5, FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _itemDetail(OrderItemEntity item) => [
  item.brand,
  item.categoryName,
  item.size,
].where((value) => value.trim().isNotEmpty).join(' · ');

class _Summary extends StatelessWidget {
  final OrderEntity order;

  const _Summary(this.order);

  @override
  Widget build(BuildContext context) {
    final discount = order.discount.abs();
    final summary = [
      ('Subtotal', order.subtotal),
      if (discount > 0) ('Discount', -discount),
      ('Tax', order.tax),
      ('Shipping', order.shippingFee),
      ('Total', order.total),
    ];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment summary', style: _font(14, FontWeight.w700)),
          const SizedBox(height: 10),
          ...summary.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.$1,
                    style: _font(
                      12,
                      item.$1 == 'Total' ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    _money(item.$2),
                    style: _font(
                      12,
                      item.$1 == 'Total' ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Delivery extends StatelessWidget {
  final OrderEntity order;

  const _Delivery(this.order);

  @override
  Widget build(BuildContext context) {
    final address =
        order.address?.values
            .where((value) => value != null && value.toString().isNotEmpty)
            .join(', ') ??
        '';

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery & payment', style: _font(14, FontWeight.w700)),
          const SizedBox(height: 9),
          Text(
            'Delivery: ${_pretty(order.deliveryType)}',
            style: _font(12, FontWeight.w400),
          ),
          Text(
            'Payment: ${_pretty(order.paymentMethod)}',
            style: _font(12, FontWeight.w400),
          ),
          if (address.isNotEmpty)
            Text('Address: $address', style: _font(12, FontWeight.w400)),
          if (order.estimatedDeliveryTime?.isNotEmpty == true)
            Text(
              'Estimated: ${order.estimatedDeliveryTime}',
              style: _font(12, FontWeight.w400),
            ),
        ],
      ),
    );
  }
}

class _Notes extends StatelessWidget {
  final OrderEntity order;

  const _Notes(this.order);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes', style: _font(14, FontWeight.w700)),
          if ((order.notes ?? '').isNotEmpty)
            Text(order.notes!, style: _font(12, FontWeight.w400)),
          if ((order.specialNote ?? '').isNotEmpty)
            Text(order.specialNote!, style: _font(12, FontWeight.w400)),
        ],
      ),
    );
  }
}

TextStyle _font(
  double size,
  FontWeight weight, [
  Color color = const Color(0xff292635),
]) {
  return GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
}

BoxDecoration _box() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xffefecf6)),
    boxShadow: const [
      BoxShadow(color: Color(0x0d251a56), blurRadius: 15, offset: Offset(0, 6)),
    ],
  );
}

String _money(double value) {
  return '${value < 0 ? '-' : ''}\$${value.abs().toStringAsFixed(2)}';
}

String _pretty(String value) {
  if (value.trim().isEmpty) {
    return '—';
  }

  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String _date(String? value) {
  if (value == null || value.isEmpty) {
    return '—';
  }

  final date = DateTime.tryParse(value);

  if (date == null) {
    return value;
  }

  return '${date.day}/${date.month}/${date.year}';
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'delivered':
      return const Color(0xff159b63);

    case 'cancelled':
      return const Color(0xffdf4b5a);

    case 'out_for_delivery':
      return const Color(0xffde8b18);

    case 'processing':
    case 'shipping':
      return const Color(0xff6251d7);

    default:
      return const Color(0xff4878d0);
  }
}

IconData _statusIcon(String status) {
  final normalizedStatus = status.toLowerCase();

  if (normalizedStatus == 'delivered') {
    return Icons.check_circle_rounded;
  }

  if (normalizedStatus == 'cancelled') {
    return Icons.cancel_rounded;
  }

  if (normalizedStatus == 'out_for_delivery') {
    return Icons.delivery_dining_rounded;
  }

  return Icons.inventory_2_rounded;
}
