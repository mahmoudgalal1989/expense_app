import 'package:expense_app/features/category/presentation/widgets/suggested_category_item.dart';
import 'package:expense_app/features/category/presentation/widgets/my_category_item.dart';
import 'package:expense_app/features/category/presentation/widgets/add_category_bottom_sheet.dart';
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
import 'package:expense_app/core/bloc/app_settings_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  CategoryType _currentType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    // No need to initialize here as main.dart already does it
    // Just listen to the existing AppSettingsBloc state
  }

  void _onSegmentChanged(int index) {
    setState(() {
      _currentType = index == 0 ? CategoryType.expense : CategoryType.income;
    });
  }

  void _addCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddCategoryBottomSheet(
          onSave: (name, icon, type, borderColor, {String? categoryId}) {
            final appSettingsBloc = context.read<AppSettingsBloc>();
            if (categoryId != null) {
              final updatedCategory = Category(
                id: categoryId,
                name: name,
                icon: icon,
                type: type,
                borderColor: borderColor,
              );
              appSettingsBloc.add(CategoryUpdated(updatedCategory));
            } else {
              final newId = DateTime.now().millisecondsSinceEpoch.toString();
              final newCategory = Category(
                id: newId,
                name: name,
                icon: icon,
                type: type,
                borderColor: borderColor,
              );
              appSettingsBloc.add(CategoryAdded(newCategory));
            }
          },
        ),
      ),
    );
  }

  void _editCategory(Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddCategoryBottomSheet(
          categoryToEdit: category,
          onSave: (name, icon, type, borderColor, {String? categoryId}) {
            final appSettingsBloc = context.read<AppSettingsBloc>();
            if (categoryId != null) {
              final updatedCategory = Category(
                id: categoryId,
                name: name,
                icon: icon,
                type: type,
                borderColor: borderColor,
              );
              appSettingsBloc.add(CategoryUpdated(updatedCategory));
            } else {
              final newId = DateTime.now().millisecondsSinceEpoch.toString();
              final newCategory = Category(
                id: newId,
                name: name,
                icon: icon,
                type: type,
                borderColor: borderColor,
              );
              appSettingsBloc.add(CategoryAdded(newCategory));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('CategoryScreen build method called');
    return Scaffold(
      backgroundColor: AppColors.bgPrimaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_left.svg',
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: QuantoText.h3('Categories', color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedToggleSwitch(
              values: const ['Expense', 'Income'],
              onToggleCallback: _onSegmentChanged,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: BlocBuilder<AppSettingsBloc, AppSettingsState>(
                builder: (context, state) {
                  try {
                    print('CategoryScreen BlocBuilder - Current state: ${state.runtimeType}');
                    
                    if (state is AppSettingsInitial || state is AppSettingsLoading || state is CategoriesUpdating) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is AppSettingsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QuantoText.bodyMedium(
                              state.message,
                              color: Colors.red,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            QuantoButton(
                              onPressed: () {
                                context.read<AppSettingsBloc>().add(
                                  const InitializeAppSettings(),
                                );
                              },
                              text: 'Retry',
                              buttonType: QuantoButtonType.primary,
                            ),
                          ],
                        ),
                      );
                    } else if (state is AppSettingsLoaded) {
                      final userCategories = state.getCategoriesByType(_currentType);
                      final suggestedCategories = state.getSuggestedCategoriesByType(_currentType);
                      
                      print('CategoryScreen - User categories: ${userCategories.length}');
                      print('CategoryScreen - Suggested categories: ${suggestedCategories.length}');
                      
                      if (userCategories.isEmpty && suggestedCategories.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: AppColors.textSecondaryDark,
                            ),
                            const SizedBox(height: 16),
                            QuantoText.h2('Add your first categories', color: Colors.white),
                            const SizedBox(height: 8),
                            QuantoText.bodyMedium(
                              'Start organizing your transactions by adding the categories that matter to you.',
                              color: AppColors.textSecondaryDark,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      }

                      // Build list of slivers to show both user and suggested categories
                      List<Widget> slivers = [];
                      
                      if (userCategories.isNotEmpty) {
                        slivers.add(_buildUserCategoriesList(userCategories));
                      }
                      
                      if (suggestedCategories.isNotEmpty) {
                        print('Adding suggested categories sliver with ${suggestedCategories.length} categories');
                        slivers.add(_buildSuggestedCategoriesList(context, suggestedCategories));
                      } else {
                        print('No suggested categories to add');
                      }
                      
                      return CustomScrollView(
                        scrollBehavior: NoGlowScrollBehavior(),
                        slivers: slivers,
                      );
                    }

                    return Center(
                      child: Text(
                        'Unknown state',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } catch (e, stackTrace) {
                    print('Error in CategoryScreen BlocBuilder: $e');
                    print('StackTrace: $stackTrace');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error rendering categories',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            e.toString(),
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: AppColors.premium,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.category_outlined,
            size: 64,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildUserCategoriesList(List<Category> categories) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
              child: QuantoText.bodyMedium('My categories',
                  color: AppColors.textSecondaryDark),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.opacity8,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  // For now, we'll handle reordering by getting current categories and reordering them
                  final currentState = context.read<AppSettingsBloc>().state;
                  if (currentState is AppSettingsLoaded) {
                    final currentCategories = currentState.getCategoriesByType(_currentType);
                    final reorderedCategories = List<Category>.from(currentCategories);
                    final item = reorderedCategories.removeAt(oldIndex);
                    reorderedCategories.insert(newIndex, item);
                    
                    context.read<AppSettingsBloc>().add(
                      CategoriesReordered(
                        reorderedCategories: reorderedCategories,
                        type: _currentType,
                      ),
                    );
                  }
                },
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
                    key: ValueKey(category.id),
                    child: Column(
                      children: [
                        MyCategoryItem(
                          icon: category.icon,
                          name: category.name,
                          borderColor: category.borderColor ?? const Color(0xFF6366F1),
                          onTap: () => _editCategory(category),
                        ),
                        if (index < categories.length - 1) const QuantoDivider(),
                      ],
                    ),
                  );
                },
              ),
            ),
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
                      context.read<AppSettingsBloc>().add(CategoryAdded(category));
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
