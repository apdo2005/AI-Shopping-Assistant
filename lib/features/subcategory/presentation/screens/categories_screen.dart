import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_shopping_assistant/core/constants/app_colors.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import '../../data/datasources/subcategory_remote_datasource.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../cubit/subcategory_cubit.dart';
import 'meals_screen.dart';

/// الأيقونات الخاصة بكل category حسب الـ id
const Map<String, IconData> _categoryIcons = {
  '1': Icons.eco_rounded, // Vegetables
  '2': Icons.local_florist_rounded, // Fruits
  '3': Icons.water_drop_rounded, // Dairy
  '4': Icons.kebab_dining_rounded, // Meat
  '5': Icons.bakery_dining_rounded, // Bakery
};

const Map<String, Color> _categoryColors = {
  '1': Color(0xFF4CAF50),
  '2': Color(0xFFFF9800),
  '3': Color(0xFF2196F3),
  '4': Color(0xFFE53935),
  '5': Color(0xFF8D6E63),
};

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SubcategoryCubit(SubcategoryRemoteDataSourceImpl(DioHelper.dio))
            ..fetchGroupedSubcategories(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SubcategoryCubit, SubcategoryState>(
        builder: (context, state) {
          if (state is SubcategoryLoading || state is SubcategoryInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            );
          }
          if (state is SubcategoryError) {
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
                    style: const TextStyle(color: AppColors.textSecondary),
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
                    onPressed: () => context
                        .read<SubcategoryCubit>()
                        .fetchGroupedSubcategories(),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is SubcategoryLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.groups.length,
              itemBuilder: (context, i) =>
                  _CategoryGroupCard(group: state.groups[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Category Group Card ───────────────────────────────────────────────────────
class _CategoryGroupCard extends StatelessWidget {
  final CategoryGroupEntity group;
  const _CategoryGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[group.categoryId] ?? AppColors.blue;
    final icon = _categoryIcons[group.categoryId] ?? Icons.category_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  group.categoryName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                Text(
                  '${group.subcategories.length} sections',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // ── Subcategories Grid ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: group.subcategories
                  .map(
                    (sub) => _SubcategoryChip(subcategory: sub, color: color),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subcategory Chip ──────────────────────────────────────────────────────────
class _SubcategoryChip extends StatelessWidget {
  final SubcategoryEntity subcategory;
  final Color color;
  const _SubcategoryChip({required this.subcategory, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealsScreen(
              subcategoryId: subcategory.id,
              subcategoryName: subcategory.name,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subcategory.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${subcategory.mealsCount}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
