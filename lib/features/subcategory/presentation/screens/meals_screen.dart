import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_shopping_assistant/core/constants/app_colors.dart';
import 'package:ai_shopping_assistant/core/constants/dio_helper.dart';
import '../../data/datasources/subcategory_remote_datasource.dart';
import '../../domain/entities/meal_entity.dart';
import '../cubit/subcategory_cubit.dart';

class MealsScreen extends StatelessWidget {
  final String subcategoryId;
  final String subcategoryName;

  const MealsScreen({
    super.key,
    required this.subcategoryId,
    required this.subcategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SubcategoryCubit(SubcategoryRemoteDataSourceImpl(DioHelper.dio))
            ..fetchMeals(subcategoryId),
      child: _MealsView(
        subcategoryName: subcategoryName,
        subcategoryId: subcategoryId,
      ),
    );
  }
}

class _MealsView extends StatelessWidget {
  final String subcategoryName;
  final String subcategoryId;
  
  const _MealsView({
    required this.subcategoryName,
    required this.subcategoryId,
  });

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          subcategoryName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SubcategoryCubit, SubcategoryState>(
        builder: (context, state) {
          if (state is MealsLoading ||
              state is SubcategoryLoading ||
              state is SubcategoryInitial) {
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
                        .fetchMeals(subcategoryId),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is MealsLoaded) {
            if (state.meals.isEmpty) {
              return const Center(
                child: Text(
                  'No meals available',
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
                childAspectRatio: 0.72,
              ),
              itemCount: state.meals.length,
              itemBuilder: (context, index) =>
                  _MealCard(meal: state.meals[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MealCard extends StatefulWidget {
  final MealEntity meal;
  const _MealCard({required this.meal});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    return Container(
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
          // ── Image ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: meal.imageUrl.isNotEmpty
                    ? Image.network(
                        meal.imageUrl,
                        height: 130,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 130,
                          // color: AppColors.netural,
                          child: Center(
                            child: const Icon(
                              Icons.fastfood_rounded,
                              color: AppColors.textSecondary,
                              size: 40,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 130,
                        color: AppColors.netural,
                        child: const Icon(
                          Icons.fastfood_rounded,
                          color: AppColors.textSecondary,
                          size: 40,
                        ),
                      ),
              ),
              // Favorite button
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _isFavorite = !_isFavorite),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 17,
                      color: _isFavorite ? AppColors.red : Colors.grey,
                    ),
                  ),
                ),
              ),
              // Offer badge
              if (meal.hasOffer)
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
          // ── Info ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (meal.description.isNotEmpty)
                        Text(
                          meal.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (meal.hasOffer && meal.discountPrice != null)
                            Text(
                              '\$${meal.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '\$${meal.finalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Add to cart button
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${meal.title} added to cart'),
                              backgroundColor: AppColors.blue,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          width: 30,
                          height: 30,
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
                      ),
                    ],
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
