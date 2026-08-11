import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../bloc/home_cubit.dart';
import 'package:ai_shopping_assistant/core/constants/app_colors.dart';
import 'package:ai_shopping_assistant/features/subcategory/presentation/screens/categories_screen.dart';
import 'package:ai_shopping_assistant/features/subcategory/presentation/screens/subcategory_list_screen.dart';
import 'package:ai_shopping_assistant/features/subcategory/presentation/screens/meals_screen.dart';
import 'package:ai_shopping_assistant/features/homescreen/presentation/pages/product_details_screen.dart';
import 'package:ai_shopping_assistant/features/homescreen/presentation/pages/search_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blue, Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AURA SHOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your personal AI assistant',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.shopping_basket_rounded,
                    title: 'My Orders',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(color: Color(0xFFE5E7EB)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 24, bottom: 8, top: 4),
                    child: Text(
                      'LEGAL',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            );
          }
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.read<HomeCubit>().fetchHomeData(),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is HomeLoaded) {
            return _buildHomeBody(context, state.categories, state.products);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomeBody(
    BuildContext context,
    List<CategoryEntity> categories,
    List<ProductEntity> products,
  ) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _SearchBar(),
          ),
        ),
        SliverToBoxAdapter(child: _CategoriesSection(categories: categories)),
        SliverToBoxAdapter(child: _PersonalizedSection(products: products)),
        SliverToBoxAdapter(child: _TrendingSection(products: products)),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      snap: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        'AURA SHOP',
        style: TextStyle(
          color: AppColors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppColors.textSecondary, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SearchScreen(initialVoiceSearch: false),
        ),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'What are you looking for today?',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.mic_none_rounded,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SearchScreen(initialVoiceSearch: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Categories Section ────────────────────────────────────────────────────────
class _CategoriesSection extends StatelessWidget {
  final List<CategoryEntity> categories;
  const _CategoriesSection({required this.categories});

  // الـ icons والألوان الخاصة بكل category حسب الـ id
  static const _catColors = {
    '1': Color(0xFF4CAF50),
    '2': Color(0xFFFF9800),
    '3': Color(0xFF2196F3),
    '4': Color(0xFFE53935),
    '5': Color(0xFF8D6E63),
  };

  static const _fallbackData = [
    {'icon': Icons.eco_rounded, 'label': 'Vegetables', 'id': '1'},
    {'icon': Icons.local_florist_rounded, 'label': 'Fruits', 'id': '2'},
    {'icon': Icons.water_drop_rounded, 'label': 'Dairy', 'id': '3'},
    {'icon': Icons.kebab_dining_rounded, 'label': 'Meat', 'id': '4'},
    {'icon': Icons.bakery_dining_rounded, 'label': 'Bakery', 'id': '5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppColors.blue, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final id = cat.id;
                final color = _catColors[id] ?? AppColors.blue;
                final label = cat.name;
                final iconUrl = cat.iconUrl.isNotEmpty ? cat.iconUrl : null;
                return _CategoryItem(
                  icon: Icons.category_rounded,
                  label: label,
                  iconUrl: iconUrl,
                  categoryId: id,
                  color: color,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? iconUrl;
  final String? categoryId;
  final Color color;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.iconUrl,
    required this.categoryId,
    this.color = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: categoryId != null
            ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MealsScreen(
                    subcategoryId: categoryId!,
                    subcategoryName: label,
                  ),
                ),
              )
            : null,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: iconUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        iconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(icon, color: color, size: 28),
                      ),
                    )
                  : Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Personalized For You ──────────────────────────────────────────────────────
class _PersonalizedSection extends StatelessWidget {
  final List<ProductEntity> products;
  const _PersonalizedSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Personalized for You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_left,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppColors.blue, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          products.isEmpty
              ? const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : SizedBox(
                  height: 230,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        _ProductCard(product: products[index]),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Container(
                              height: 120,
                              // color: AppColors.netural,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size  : 30,
                                color: Color.fromARGB(255, 61, 72, 109),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 120,
                          color: AppColors.netural,
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.textSecondary,
                            size: 40,
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (product.hasOffer)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'OFFER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.finalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
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

// ─── Trending Now ──────────────────────────────────────────────────────────────
class _TrendingSection extends StatelessWidget {
  final List<ProductEntity> products;
  const _TrendingSection({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final featured = products.where((p) => p.isFeatured).toList();
    final trendingList = featured.isNotEmpty ? featured : products;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Trending Now',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: trendingList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _TrendingCard(product: trendingList[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final ProductEntity product;
  const _TrendingCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      ),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.netural,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.netural,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.netural,
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.textSecondary,
                        size: 40,
                      ),
                    ),
              // gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.description.isNotEmpty
                            ? product.description
                                  .split(' ')
                                  .take(2)
                                  .join(' ')
                                  .toUpperCase()
                            : 'TRENDING',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
