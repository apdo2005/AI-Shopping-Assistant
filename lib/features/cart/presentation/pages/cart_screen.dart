import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_shopping_assistant/shared/snakbar.dart';
import '../../domain/entities/cart_entity.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../theme/cart_theme.dart';
import '../widgets/cart_network_image.dart';
import '../widgets/shimmer_placeholder.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CartTheme.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: CartTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const _CartHeader(),
              Expanded(
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _buildBody(context, state),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state is CartInitial || state is CartLoading) {
      return const _CartLoadingSkeleton(key: ValueKey('loading'));
    }
    if (state is CartError) {
      return _CartErrorView(
        key: const ValueKey('error'),
        message: state.message,
        onRetry: context.read<CartCubit>().load,
      );
    }
    if (state is CartEmpty) {
      return const _EmptyCartView(key: ValueKey('empty'));
    }
    if (state is CartLoaded) {
      return RefreshIndicator(
        key: const ValueKey('loaded'),
        color: CartTheme.primary,
        onRefresh: context.read<CartCubit>().load,
        child: _CartBody(cart: state.cart, pending: state.pendingItemIds),
      );
    }
    return const SizedBox(key: ValueKey('blank'));
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 4),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: CartTheme.textPrimary,
              ),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Center(
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  final count = state is CartLoaded ? state.cart.itemCount : 0;
                  return Text(
                    'My Cart${count > 0 ? ' ($count ${count == 1 ? 'item' : 'items'})' : ''}',
                    style: CartTheme.font(size: 16, weight: FontWeight.w700),
                  );
                },
              ),
            ),
          ),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is! CartLoaded) return const SizedBox(width: 48);
              return PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: CartTheme.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabled: !state.isClearing,
                onSelected: (value) {
                  if (value == 'clear') _confirmClear(context);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: CartTheme.danger,
                        ),
                        const SizedBox(width: 8),
                        Text('Clear Cart', style: CartTheme.font(size: 13)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Clear cart?',
          style: CartTheme.font(size: 16, weight: FontWeight.w700),
        ),
        content: Text(
          'This will remove all items from your cart.',
          style: CartTheme.font(size: 13, color: CartTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: CartTheme.font(size: 13, color: CartTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cartCubit.clear().then((error) {
                if (error != null && context.mounted) {
                  CustomSnackBar().errorBar(context, error);
                }
              });
            },
            child: Text(
              'Clear',
              style: CartTheme.font(
                size: 13,
                weight: FontWeight.w700,
                color: CartTheme.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  final CartEntity cart;
  final Set<int> pending;

  const _CartBody({required this.cart, required this.pending});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = cart.items[index];
              final isLast = index == cart.items.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: _CartItemCard(
                    key: ValueKey(item.id),
                    item: item,
                    pending: pending.contains(item.id),
                  ),
                ),
              );
            }, childCount: cart.items.length),
          ),
        ),
        SliverPadding(
          // Extra bottom padding clears the floating CurvedNavigationBar
          // used by MainWrapperScreen (extendBody: true), matching the
          // original screen's spacing so the checkout button is never
          // hidden behind it.
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
          sliver: SliverToBoxAdapter(child: _OrderSummary(cart: cart)),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final CartItemEntity item;
  final bool pending;

  const _CartItemCard({super.key, required this.item, required this.pending});

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  bool _isIncrementing = false;

  Future<void> _increment() async {
    if (_isIncrementing || widget.pending) return;
    setState(() => _isIncrementing = true);
    // Reuses the existing, unmodified CartCubit.addItem — the same method
    // already used by every "Add to Cart" button across the app.
    final success = await context.read<CartCubit>().addItem(
      widget.item.meal.id,
      quantity: 1,
    );
    if (!mounted) return;
    setState(() => _isIncrementing = false);
    if (!success) {
      CustomSnackBar().errorBar(
        context,
        'Unable to update quantity right now.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.item.meal;
    final detailParts = [
      meal.brand,
      meal.categoryName,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    final detail = detailParts.isNotEmpty ? detailParts.join(' · ') : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: CartTheme.cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CartNetworkImage(imageUrl: meal.imageUrl, size: 76),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CartTheme.font(
                          size: 12.5,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _RemoveButton(item: widget.item, pending: widget.pending),
                  ],
                ),
                if (detail != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CartTheme.font(
                      size: 10.5,
                      color: CartTheme.textSecondary,
                    ),
                  ),
                ],
                if (meal.size != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    meal.size!,
                    style: CartTheme.font(
                      size: 10.5,
                      color: CartTheme.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '\$${widget.item.unitPrice.toStringAsFixed(2)}',
                            style: CartTheme.font(
                              size: 13.5,
                              weight: FontWeight.w700,
                              color: CartTheme.primary,
                            ),
                          ),
                          if (widget.item.discountAmount > 0) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: CartTheme.success.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Save \$${widget.item.discountAmount.toStringAsFixed(2)}',
                                  overflow: TextOverflow.ellipsis,
                                  style: CartTheme.font(
                                    size: 9,
                                    weight: FontWeight.w600,
                                    color: CartTheme.success,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _QuantityStepper(
                      quantity: widget.item.quantity,
                      isIncrementing: _isIncrementing,
                      onIncrement: _increment,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final CartItemEntity item;
  final bool pending;

  const _RemoveButton({required this.item, required this.pending});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: pending
          ? null
          : () async {
              final error = await context.read<CartCubit>().removeItem(item.id);
              if (error != null && context.mounted) {
                CustomSnackBar().errorBar(context, error);
              }
            },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: pending
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CartTheme.textMuted,
                ),
              )
            : const Icon(
                Icons.close_rounded,
                size: 16,
                color: CartTheme.textMuted,
              ),
      ),
    );
  }
}

/// Compact, premium quantity stepper.
///
/// NOTE (API boundary): the Cart API only exposes add / remove / clear —
/// there is no "decrease quantity" endpoint. The `+` control reuses the
/// existing, unmodified `CartCubit.addItem` call used everywhere else in
/// the app. The `-` control is intentionally presentational (matching the
/// original implementation) since decrementing quantity isn't something
/// the current backend supports; wire it up once that capability exists.
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool isIncrementing;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.isIncrementing,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: CartTheme.stepperBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.remove_rounded,
              size: 14,
              color: CartTheme.textMuted,
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 16),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: CartTheme.font(size: 12, weight: FontWeight.w700),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: isIncrementing ? null : onIncrement,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: isIncrementing
                  ? const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CartTheme.primary,
                      ),
                    )
                  : const Icon(
                      Icons.add_rounded,
                      size: 14,
                      color: CartTheme.primary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartEntity cart;

  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final discount = cart.discount.abs();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CartTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: CartTheme.font(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _line('Subtotal', cart.subtotal),
          _line('Shipping', 0, free: true),
          _line('Estimated Tax', cart.tax),
          if (discount > 0) _line('Discount', -discount),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: CartTheme.border),
          ),
          _line('Total', cart.total, bold: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: CartTheme.primaryGradient,
                borderRadius: BorderRadius.circular(13),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x336C4FF6),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(cart: cart),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Proceed to Checkout',
                          style: CartTheme.font(
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
        ],
      ),
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

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CartTheme.primary.withValues(alpha: 0.10),
                    CartTheme.primary.withValues(alpha: 0.04),
                  ],
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: CartTheme.primary,
                size: 52,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Your cart is empty',
              style: CartTheme.font(size: 19, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\u2019t added anything yet.\nStart exploring to find something you love.',
              textAlign: TextAlign.center,
              style: CartTheme.font(
                size: 12.5,
                color: CartTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: CartTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        'Continue Shopping',
                        style: CartTheme.font(
                          size: 13.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

class _CartErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CartErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CartTheme.danger.withValues(alpha: 0.08),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: CartTheme.danger,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: CartTheme.font(size: 16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: CartTheme.font(
                size: 12.5,
                color: CartTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CartTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Try Again',
                  style: CartTheme.font(
                    size: 13,
                    weight: FontWeight.w600,
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

class _CartLoadingSkeleton extends StatelessWidget {
  const _CartLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 100),
      children: [
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: CartTheme.cardDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(
                    width: 76,
                    height: 76,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerBox(width: double.infinity, height: 12),
                        SizedBox(height: 8),
                        ShimmerBox(width: 90, height: 10),
                        SizedBox(height: 14),
                        ShimmerBox(width: 60, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: CartTheme.cardDecoration,
          child: const Column(
            children: [
              ShimmerBox(width: double.infinity, height: 14),
              SizedBox(height: 16),
              ShimmerBox(width: double.infinity, height: 10),
              SizedBox(height: 10),
              ShimmerBox(width: double.infinity, height: 10),
              SizedBox(height: 10),
              ShimmerBox(width: double.infinity, height: 10),
              SizedBox(height: 16),
              ShimmerBox(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(13)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
