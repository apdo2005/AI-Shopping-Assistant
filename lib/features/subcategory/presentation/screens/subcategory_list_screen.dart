import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_shopping_assistant/core/constants/app_colors.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import '../../data/datasources/subcategory_remote_datasource.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../cubit/subcategory_cubit.dart';
import 'meals_screen.dart';

const Map<String, IconData> _catIcons = {
  '1': Icons.eco_rounded,
  '2': Icons.local_florist_rounded,
  '3': Icons.water_drop_rounded,
  '4': Icons.kebab_dining_rounded,
  '5': Icons.bakery_dining_rounded,
};

const Map<String, Color> _catColors = {
  '1': Color(0xFF4CAF50),
  '2': Color(0xFFFF9800),
  '3': Color(0xFF2196F3),
  '4': Color(0xFFE53935),
  '5': Color(0xFF8D6E63),
};

/// شاشة تعرض الـ subcategories الخاصة بـ category معينة
class SubcategoryListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const SubcategoryListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SubcategoryCubit(SubcategoryRemoteDataSourceImpl(DioHelper.dio))
            ..fetchGroupedSubcategories(),
      child: _SubcategoryListView(
        categoryId: categoryId,
        categoryName: categoryName,
      ),
    );
  }
}

class _SubcategoryListView extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const _SubcategoryListView({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final color = _catColors[categoryId] ?? AppColors.blue;
    final icon = _catIcons[categoryId] ?? Icons.category_rounded;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              categoryName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
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
            // فلتر الـ groups عشان نجيب الـ category المطلوبة بس
            final group = state.groups.firstWhere(
              (g) => g.categoryId == categoryId,
              orElse: () => CategoryGroupEntity(
                categoryId: categoryId,
                categoryName: categoryName,
                subcategories: [],
              ),
            );

            if (group.subcategories.isEmpty) {
              return const Center(
                child: Text(
                  'No subcategories found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: group.subcategories.length,
              itemBuilder: (context, index) => _SubcategoryCard(
                subcategory: group.subcategories[index],
                color: color,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SubcategoryCard extends StatelessWidget {
  final SubcategoryEntity subcategory;
  final Color color;

  const _SubcategoryCard({required this.subcategory, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealsScreen(
            subcategoryId: subcategory.id,
            subcategoryName: subcategory.name,
          ),
        ),
      ),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // صورة أو icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: subcategory.imageUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        subcategory.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.category_rounded,
                          color: color,
                          size: 28,
                        ),
                      ),
                    )
                  : Icon(Icons.category_rounded, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subcategory.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${subcategory.mealsCount} items',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
