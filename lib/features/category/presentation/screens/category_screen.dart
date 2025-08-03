import 'package:expense_app/features/category/presentation/widgets/suggested_category_item.dart';
import 'package:expense_app/widgets/quanto_button.dart';
import 'package:expense_app/widgets/quanto_divider.dart';
import 'package:expense_app/widgets/animated_toggle_switch.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:expense_app/widgets/no_glow_scroll_behavior.dart';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_app/features/category/presentation/bloc/category_event.dart';
import 'package:expense_app/features/category/presentation/bloc/category_state.dart';
import 'package:expense_app/features/category/di/category_injection_container.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  void _onSegmentChanged(int index) {
    final type = index == 0 ? CategoryType.expense : CategoryType.income;
    context.read<CategoryBloc>().add(LoadCategories(type));
  }

  void _addCategory() {
    // TODO: Implement add category logic
    print('Add new category');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CategoryBloc>()..add(LoadCategories(CategoryType.expense)),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundGradient[0],
                    AppColors.backgroundGradient[1],
                  ],
                ),
              ),
            ),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading || state is CategoryInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (state is CategoryError) {
                  return Center(
                    child: QuantoText(state.message, color: Colors.white),
                  );
                }
                if (state is CategoryLoaded) {
                  return SafeArea(
                    child: ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: CustomScrollView(
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            backgroundColor: Colors.transparent,
                            flexibleSpace: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                            leading: IconButton(
                              icon: SvgPicture.asset(
                                'assets/svg/back_btn.svg',
                                colorFilter: const ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            title: AnimatedToggleSwitch(
                              values: const ['Expense', 'Income'],
                              onToggleCallback: _onSegmentChanged,
                            ),
                            centerTitle: true,
                            actions: [
                              TextButton(
                                onPressed: _addCategory,
                                child: QuantoText.buttonMedium('New',
                                    color: AppColors.light0),
                              ),
                            ],
                            pinned: true,
                          ),
                          if (state.userCategories.isEmpty)
                            _buildEmptyState()
                          else
                            _buildUserCategoriesList(state.userCategories),
                          if (state.suggestedCategories.isNotEmpty)
                            _buildSuggestedCategoriesList(
                                context, state.suggestedCategories),
                          const SliverToBoxAdapter(
                              child:
                                  SizedBox(height: 40)), // Add bottom padding
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
        child: Column(
          children: [
            SvgPicture.asset('assets/svg/category_empty.svg', height: 100),
            const SizedBox(height: 24),
            QuantoText.h2('Add your first categories', color: Colors.white),
            const SizedBox(height: 8),
            QuantoText.bodyMedium(
              'Start organizing your transactions by adding the categories that matter to you.',
              color: AppColors.textSecondaryDark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            QuantoButton(
              onPressed: _addCategory,
              text: 'New category',
              buttonType: QuantoButtonType.primary,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCategoriesList(List<Category> categories) {
    // TODO: Implement UI for user-added categories
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuantoText.h3('Your Categories', color: Colors.white),
            const SizedBox(height: 16),
            ...categories.map((c) => QuantoText(c.name, color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedCategoriesList(
      BuildContext context, List<Category> categories) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
              child: QuantoText.bodyMedium('Suggested categories',
                  color: AppColors.textSecondaryDark),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.opacity8,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return SuggestedCategoryItem(
                    icon: category.icon,
                    name: category.name,
                    onAdd: () {
                      context.read<CategoryBloc>().add(AddCategory(category));
                    },
                  );
                },
                separatorBuilder: (context, index) => const QuantoDivider(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
