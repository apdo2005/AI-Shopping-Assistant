import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_cubit.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<OrdersCubit, OrdersState>(
    builder: (context, state) {
      if (state is OrdersInitial) return const _Loading();
      if (state is OrdersLoading) return const _Loading();
      if (state is OrdersError)
        return _Error(
          message: state.message,
          onRetry: () => context.read<OrdersCubit>().load(),
        );
      final orders = (state as OrdersLoaded).orders;
      return Scaffold(
        backgroundColor: const Color(0xfffaf9ff),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text('Orders', style: _font(18, FontWeight.w700)),
          actions: [
            IconButton(
              tooltip: 'Track active order',
              onPressed: () => _track(context),
              icon: const Icon(
                Icons.my_location_rounded,
                color: Color(0xff6251d7),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => context.read<OrdersCubit>().load(),
          child: orders.isEmpty
              ? _Empty(onTrack: () => _track(context))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _Card(order: orders[i]),
                ),
        ),
      );
    },
  );
  Future<void> _track(BuildContext context) async {
    final cubit = context.read<OrdersCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final order = await cubit.track();
      if (!context.mounted) return;
      Navigator.pop(context);
      if (order == null || order.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No active order. Browse your previous orders below.',
            ),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OrderDetailsScreen(orderId: order.id!, initial: order),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class _Card extends StatelessWidget {
  final OrderEntity order;
  const _Card({required this.order});
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return InkWell(
      onTap: () => order.id == null
          ? null
          : Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    OrderDetailsScreen(orderId: order.id!, initial: order),
              ),
            ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _box(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(order.status),
                    color: color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.number.isEmpty
                            ? 'Order'
                            : 'Order #${order.number}',
                        style: _font(14, FontWeight.w700),
                      ),
                      Text(
                        _date(order.createdAt ?? order.placedAt),
                        style: _font(
                          11,
                          FontWeight.w400,
                          const Color(0xff89859c),
                        ),
                      ),
                    ],
                  ),
                ),
                _Chip(status: order.status),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _Metric(label: 'Items', value: '${order.itemCount}'),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Delivery',
                    value: _pretty(order.deliveryType),
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Total',
                    value: _money(order.total),
                    align: TextAlign.end,
                  ),
                ),
              ],
            ),
            if (order.estimatedDeliveryTime?.isNotEmpty == true) ...[
              const SizedBox(height: 13),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Color(0xff6251d7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Estimated ${order.estimatedDeliveryTime}',
                    style: _font(
                      11.5,
                      FontWeight.w500,
                      const Color(0xff6251d7),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 25),
            Row(
              children: [
                Text(
                  'View details',
                  style: _font(12, FontWeight.w700, const Color(0xff6251d7)),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: Color(0xff6251d7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final TextAlign align;
  const _Metric({
    required this.label,
    required this.value,
    this.align = TextAlign.start,
  });
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: align == TextAlign.end
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(label, style: _font(10.5, FontWeight.w400, const Color(0xff918da1))),
      const SizedBox(height: 3),
      Text(value, style: _font(12, FontWeight.w600)),
    ],
  );
}

class _Chip extends StatelessWidget {
  final String status;
  const _Chip({required this.status});
  @override
  Widget build(BuildContext c) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_pretty(status), style: _font(10.5, FontWeight.w700, color)),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onTrack;
  const _Empty({required this.onTrack});
  @override
  Widget build(BuildContext c) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(30, 105, 30, 0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xffeeeaff),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Color(0xff6251d7),
              ),
            ),
            const SizedBox(height: 20),
            Text('No orders yet', style: _font(19, FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'When you place an order, its updates and receipts will live here.',
              textAlign: TextAlign.center,
              style: _font(12.5, FontWeight.w400, const Color(0xff89859c)),
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Track active order'),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _Error({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext c) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 45,
            color: Color(0xff6251d7),
          ),
          const SizedBox(height: 12),
          Text('Couldn’t load orders', style: _font(17, FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _font(12, FontWeight.w400, const Color(0xff89859c)),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext c) => const Scaffold(
    backgroundColor: Color(0xfffaf9ff),
    body: Center(child: CircularProgressIndicator()),
  );
}

TextStyle _font(
  double size,
  FontWeight weight, [
  Color color = const Color(0xff292635),
]) => GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);
BoxDecoration _box() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: const Color(0xffefecf6)),
  boxShadow: const [
    BoxShadow(color: Color(0x0d251a56), blurRadius: 15, offset: Offset(0, 6)),
  ],
);
String _money(double v) => '\$${v.toStringAsFixed(2)}';
String _pretty(String value) => value.trim().isEmpty
    ? '—'
    : value
          .replaceAll('_', ' ')
          .split(' ')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');
String _date(String? value) {
  if (value == null || value.isEmpty) return 'Date unavailable';
  final d = DateTime.tryParse(value);
  return d == null ? value : '${d.day}/${d.month}/${d.year}';
}

Color _statusColor(String s) {
  switch (s.toLowerCase()) {
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

IconData _statusIcon(String s) => s.toLowerCase() == 'delivered'
    ? Icons.check_circle_rounded
    : s.toLowerCase() == 'cancelled'
    ? Icons.cancel_rounded
    : s.toLowerCase() == 'out_for_delivery'
    ? Icons.delivery_dining_rounded
    : Icons.inventory_2_rounded;
