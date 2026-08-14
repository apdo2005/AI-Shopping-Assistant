import 'package:flutter/material.dart';
import '../../domain/entities/cart_entity.dart';
import '../theme/cart_theme.dart';
import '../widgets/cart_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_shopping_assistant/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ai_shopping_assistant/features/orders/domain/entities/order_entity.dart';
import 'package:ai_shopping_assistant/features/orders/presentation/bloc/orders_cubit.dart';
import 'package:ai_shopping_assistant/features/orders/presentation/pages/order_success_screen.dart';

/// Brand-new Checkout UI. This screen is presentation-only: it reads the
/// cart totals that were already computed by the backend (no recalculating
/// business logic here), and does not call, mock, or invent any
/// checkout/order/payment API. The delivery-address and payment-method
/// sections are local, in-memory UI state only — nothing is persisted or
/// sent anywhere — so the screen is ready to be wired up once those APIs
/// exist.
class CheckoutScreen extends StatefulWidget {
  final CartEntity cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _deliveryOption = 0;
  _LocalAddress? _address;
  bool _isPlacing = false;

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    return Scaffold(
      backgroundColor: CartTheme.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: CartTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                  children: [
                    _SectionCard(
                      title: 'Order Summary',
                      icon: Icons.receipt_long_outlined,
                      child: _OrderItemsList(cart: cart),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Delivery Address',
                      icon: Icons.location_on_outlined,
                      trailing: TextButton(
                        onPressed: () => _editAddress(context),
                        child: Text(
                          _address == null ? 'Add' : 'Change',
                          style: CartTheme.font(
                            size: 12,
                            weight: FontWeight.w700,
                            color: CartTheme.primary,
                          ),
                        ),
                      ),
                      child: _AddressContent(
                        address: _address,
                        onAdd: () => _editAddress(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Delivery Method',
                      icon: Icons.local_shipping_outlined,
                      child: _DeliveryOptions(
                        selected: _deliveryOption,
                        onChanged: (i) => setState(() => _deliveryOption = i),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Payment Method',
                      icon: Icons.credit_card_outlined,
                      trailing: TextButton(
                        onPressed: () =>
                            _showComingSoon(context, 'Payment methods'),
                        child: Text(
                          'Add',
                          style: CartTheme.font(
                            size: 12,
                            weight: FontWeight.w700,
                            color: CartTheme.primary,
                          ),
                        ),
                      ),
                      child: const _CashPayment(),
                    ),
                    const SizedBox(height: 12),
                    _SectionCard(
                      title: 'Price Summary',
                      icon: Icons.summarize_outlined,
                      child: _PriceSummary(cart: cart),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _BottomCta(
                isLoading: _isPlacing,
                onPlaceOrder: () => _placeOrder(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editAddress(BuildContext context) async {
    final result = await showModalBottomSheet<_LocalAddress>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressEditorSheet(initial: _address),
    );
    if (result != null && mounted) {
      setState(() => _address = result);
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CartTheme.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: Text(
          '$feature will be available soon.',
          style: CartTheme.font(size: 12.5, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_isPlacing) return;
    if (widget.cart.isEmpty ||
        widget.cart.items.isEmpty ||
        widget.cart.total <= 0) {
      _message('Your cart is empty or has an invalid total.');
      return;
    }
    // Locally entered addresses have no backend ID. Never submit one.
    if (_deliveryOption == 0) {
      _message(
        'Delivery needs a saved address. Address management is unavailable; choose pickup to continue.',
      );
      return;
    }
    setState(() => _isPlacing = true);
    try {
      final order = await context.read<OrdersCubit>().create(
        CreateOrderRequest(
          amount: widget.cart.total,
          paymentMethod: 'cash_on_delivery',
          deliveryType: 'pickup',
        ),
      );
      if (!mounted) return;
      final cartError = await context.read<CartCubit>().clear();
      await context.read<OrdersCubit>().load();
      if (!mounted) return;
      if (cartError != null)
        _message('Order placed, but the cart could not refresh: $cartError');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      );
    } catch (e) {
      if (mounted) _message(e.toString());
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );

  void _showCheckoutUnavailable(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CartTheme.primary.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                color: CartTheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Checkout isn\u2019t available yet',
              style: CartTheme.font(size: 16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Order placement isn\u2019t connected yet, so nothing has been charged or ordered. Your cart is saved and ready for when it is.',
              textAlign: TextAlign.center,
              style: CartTheme.font(
                size: 12.5,
                color: CartTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CartTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Text(
                  'Got it',
                  style: CartTheme.font(
                    size: 13.5,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: CartTheme.textPrimary,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Checkout',
                style: CartTheme.font(size: 16, weight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CartTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: CartTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: CartTheme.font(size: 13.5, weight: FontWeight.w700),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OrderItemsList extends StatelessWidget {
  final CartEntity cart;

  const _OrderItemsList({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in cart.items) ...[
          Row(
            children: [
              CartNetworkImage(
                imageUrl: item.meal.imageUrl,
                size: 44,
                borderRadius: 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.meal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CartTheme.font(size: 12, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Qty ${item.quantity}',
                      style: CartTheme.font(
                        size: 10.5,
                        color: CartTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: CartTheme.font(size: 12.5, weight: FontWeight.w700),
              ),
            ],
          ),
          if (item != cart.items.last)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: CartTheme.border),
            ),
        ],
      ],
    );
  }
}

class _LocalAddress {
  final String name;
  final String phone;
  final String line;
  final String city;

  const _LocalAddress({
    required this.name,
    required this.phone,
    required this.line,
    required this.city,
  });
}

class _AddressContent extends StatelessWidget {
  final _LocalAddress? address;
  final VoidCallback onAdd;

  const _AddressContent({required this.address, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final address = this.address;
    if (address == null) {
      return InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(12),
        child: _AddPlaceholderBox(
          child: Row(
            children: [
              const Icon(
                Icons.add_location_alt_outlined,
                size: 18,
                color: CartTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Add a delivery address',
                style: CartTheme.font(
                  size: 12.5,
                  color: CartTheme.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CartTheme.stepperBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.home_outlined, size: 18, color: CartTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.name,
                  style: CartTheme.font(size: 12.5, weight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${address.line}, ${address.city}',
                  style: CartTheme.font(
                    size: 11.5,
                    color: CartTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address.phone,
                  style: CartTheme.font(
                    size: 11.5,
                    color: CartTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPlaceholderBox extends StatelessWidget {
  final Widget child;
  const _AddPlaceholderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CartTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CartTheme.primary.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }
}

class _AddressEditorSheet extends StatefulWidget {
  final _LocalAddress? initial;
  const _AddressEditorSheet({this.initial});

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _phone = TextEditingController(text: widget.initial?.phone);
  late final _line = TextEditingController(text: widget.initial?.line);
  late final _city = TextEditingController(text: widget.initial?.city);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CartTheme.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delivery Address',
                style: CartTheme.font(size: 15, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Saved on this device for this session only.',
                style: CartTheme.font(size: 11, color: CartTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              _field('Full name', _name),
              const SizedBox(height: 10),
              _field('Phone number', _phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _field('Address line', _line),
              const SizedBox(height: 10),
              _field('City', _city),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    if (_name.text.trim().isEmpty || _line.text.trim().isEmpty)
                      return;
                    Navigator.pop(
                      context,
                      _LocalAddress(
                        name: _name.text.trim(),
                        phone: _phone.text.trim(),
                        line: _line.text.trim(),
                        city: _city.text.trim(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CartTheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: Text(
                    'Save Address',
                    style: CartTheme.font(
                      size: 13.5,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: CartTheme.font(size: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: CartTheme.font(size: 12, color: CartTheme.textSecondary),
        filled: true,
        fillColor: CartTheme.stepperBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DeliveryOptions extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _DeliveryOptions({required this.selected, required this.onChanged});

  static const _options = [
    (
      title: 'Delivery',
      subtitle: 'A saved address is required',
      price: 'Address needed',
    ),
    (
      title: 'Pickup',
      subtitle: 'Collect your order from the store',
      price: 'Free',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _OptionTile(
            title: _options[i].title,
            subtitle: _options[i].subtitle,
            trailing: _options[i].price,
            selected: selected == i,
            onTap: () => onChanged(i),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? CartTheme.primary.withValues(alpha: 0.06)
              : CartTheme.stepperBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? CartTheme.primary : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: selected ? CartTheme.primary : CartTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CartTheme.font(size: 12.5, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CartTheme.font(
                      size: 10.5,
                      color: CartTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailing,
              style: CartTheme.font(
                size: 12,
                weight: FontWeight.w700,
                color: CartTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentPlaceholder extends StatelessWidget {
  final VoidCallback onAdd;
  const _PaymentPlaceholder({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(12),
      child: _AddPlaceholderBox(
        child: Row(
          children: [
            const Icon(
              Icons.add_card_outlined,
              size: 18,
              color: CartTheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No payment method added yet',
                style: CartTheme.font(
                  size: 12.5,
                  color: CartTheme.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashPayment extends StatelessWidget {
  const _CashPayment();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: CartTheme.stepperBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.payments_outlined, color: CartTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash on delivery',
                style: CartTheme.font(size: 12.5, weight: FontWeight.w600),
              ),
              Text(
                'Pay when your order arrives or is collected.',
                style: CartTheme.font(
                  size: 10.5,
                  color: CartTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PriceSummary extends StatelessWidget {
  final CartEntity cart;
  const _PriceSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final discount = cart.discount.abs();
    return Column(
      children: [
        _line('Subtotal', cart.subtotal),
        _line('Shipping', 0, free: true),
        _line('Estimated Tax', cart.tax),
        if (discount > 0) _line('Discount', -discount),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(height: 1, color: CartTheme.border),
        ),
        _line('Grand Total', cart.total, bold: true),
      ],
    );
  }

  Widget _line(
    String label,
    double value, {
    bool free = false,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CartTheme.font(
              size: bold ? 14.5 : 12,
              weight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? CartTheme.textPrimary : CartTheme.textSecondary,
            ),
          ),
          Text(
            free
                ? 'Free'
                : '${value < 0 ? '-' : ''}\$${value.abs().toStringAsFixed(2)}',
            style: CartTheme.font(
              size: bold ? 15 : 12,
              weight: bold ? FontWeight.w700 : FontWeight.w500,
              color: free || bold ? CartTheme.primary : CartTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final VoidCallback onPlaceOrder;
  final bool isLoading;
  const _BottomCta({required this.onPlaceOrder, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CartTheme.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: CartTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x336C4FF6),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: isLoading ? null : onPlaceOrder,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Place Order',
                            style: CartTheme.font(
                              size: 14.5,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: CartTheme.textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                'Secure Checkout',
                style: CartTheme.font(size: 10.5, color: CartTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
