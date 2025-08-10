import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/transaction_type.dart';
import '../bloc/bloc.dart';
import '../../../../core/bloc/bloc.dart';
import '../../../../core/bloc/app_settings_event.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/widgets/add_category_bottom_sheet.dart';

/// Screen for adding new transactions
/// 
/// Provides a form interface for creating expense and income transactions
/// with category selection and amount input.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const String fontFamily = 'Sora';
  
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  String? _selectedCurrencyId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>(
      create: (context) => GetIt.instance<TransactionBloc>(),
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),
                  
                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Transaction Type Selector
                            _buildTypeSelector(),
                            
                            const SizedBox(height: 24.0),
                            
                            // Amount Input
                            _buildAmountInput(),
                            
                            const SizedBox(height: 24.0),
                            
                            // Note Input
                            _buildNoteInput(),
                            
                            const SizedBox(height: 24.0),
                            
                            // Category Selection (Placeholder)
                            _buildCategorySection(),
                            
                            const SizedBox(height: 32.0),
                            
                            // Save Button
                            _buildSaveButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  /// Builds the header with title and close button
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            color: Colors.white,
          ),
          const SizedBox(width: 8.0),
          Text(
            'Add Transaction',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the transaction type selector
  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              type: TransactionType.expense,
              label: 'Expense',
              icon: Icons.arrow_downward,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Expanded(
            child: _buildTypeOption(
              type: TransactionType.income,
              label: 'Income',
              icon: Icons.arrow_upward,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single type option
  Widget _buildTypeOption({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          // Clear selected category when type changes since categories are type-specific
          _selectedCategory = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: isSelected 
              ? Border.all(color: color, width: 2.0)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the amount input field
  Widget _buildAmountInput() {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        String currencySymbol = '\$ ';
        String currencyCode = 'USD';
        
        if (state is AppSettingsLoaded) {
          currencyCode = state.selectedCurrency.code;
          currencySymbol = '${state.selectedCurrency.symbol} ';
          // Update selected currency ID for transaction saving
          if (_selectedCurrencyId != state.selectedCurrency.code) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedCurrencyId = state.selectedCurrency.code;
              });
            });
          }
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: fontFamily,
                  ),
                ),
                if (state is AppSettingsLoaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      '${currencyCode} (${currencySymbol.trim()})',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: currencySymbol,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
              ),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  /// Builds the note input field
  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _noteController,
          decoration: InputDecoration(
            hintText: 'Add a note...',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
          ),
          style: const TextStyle(
            fontSize: 16.0,
            fontFamily: fontFamily,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  /// Builds the category selection section
  Widget _buildCategorySection() {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        if (state is AppSettingsLoaded) {
          final categories = state.getCategoriesByType(_selectedType == TransactionType.expense 
              ? CategoryType.expense 
              : CategoryType.income);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories (Optional)',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: fontFamily,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              
              // Selected category
              if (_selectedCategory != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: _buildSelectedCategoryChip(_selectedCategory!),
                ),
              
              // Available categories
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: categories.isEmpty
                    ? _buildEmptyCategoriesState()
                    : _buildCategoriesList(categories),
              ),
            ],
          );
        }
        
        return _buildCategoryLoadingState();
      },
    );
  }

  /// Builds the save button
  Widget _buildSaveButton() {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TransactionOperationInProgress;
        
        return ElevatedButton(
          onPressed: isLoading ? null : () => _saveTransaction(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Save Transaction',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: fontFamily,
                  ),
                ),
        );
      },
    );
  }

  /// Shows add category dialog
  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCategoryBottomSheet(
        onSave: (name, icon, type, borderColor, {categoryId}) {
          // Create new category
          final newCategory = Category(
            id: categoryId ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            icon: icon,
            type: type,
            borderColor: borderColor,
            order: 0, // Will be handled by the bloc
          );
          
          // Add category to AppSettingsBloc
          context.read<AppSettingsBloc>().add(CategoryAdded(newCategory));
        },
      ),
    );
  }

  /// Builds a selected category chip
  Widget _buildSelectedCategoryChip(Category category) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        setState(() {
          _selectedCategory = null;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      deleteIconColor: Theme.of(context).colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontFamily: fontFamily,
      ),
    );
  }

  /// Builds the empty categories state
  Widget _buildEmptyCategoriesState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_outlined,
            size: 48.0,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8.0),
          Text(
            'No categories available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Tap "Add" to create your first category',
            style: TextStyle(
              fontSize: 12.0,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the categories list
  Widget _buildCategoriesList(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: categories.map((category) => 
          _buildCategoryOption(category)
        ).toList(),
      ),
    );
  }

  /// Builds a single category option
  Widget _buildCategoryOption(Category category) {
    final isSelected = _selectedCategory?.id == category.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategory = null;
          } else {
            _selectedCategory = category;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the category loading state
  Widget _buildCategoryLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8.0),
          Text(
            'Loading categories...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  /// Saves the transaction
  void _saveTransaction(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim();

    context.read<TransactionBloc>().add(
      AddTransaction(
        amount: amount,
        note: note.isEmpty ? null : note,
        categoryIds: _selectedCategory != null ? [_selectedCategory!.id] : [],
        currencyId: _selectedCurrencyId ?? 'USD',
        type: _selectedType,
      ),
    );
  }
}
