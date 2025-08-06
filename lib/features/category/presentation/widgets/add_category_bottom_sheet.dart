import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:expense_app/widgets/animated_toggle_switch.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

class AddCategoryBottomSheet extends StatefulWidget {
  final Function(String name, String icon, CategoryType type, Color borderColor) onSave;

  const AddCategoryBottomSheet({
    super.key,
    required this.onSave,
  });

  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  CategoryType _selectedType = CategoryType.expense;
  Color _selectedColor = const Color(0xFFF76775); // Default pink color

  // Color palette from the design
  final List<Color> _colorPalette = [
    const Color(0xFFF76775), // Pink
    const Color(0xFFF46262), // Red
    const Color(0xFFF78667), // Orange-red
    const Color(0xFFF49862), // Orange
    const Color(0xFFFB923C), // Orange
    const Color(0xFFFBBF24), // Yellow-orange
    const Color(0xFFFACC15), // Yellow
    const Color(0xFF60A5FA), // Blue
    const Color(0xFF11B8FF), // Light blue
    const Color(0xFF22D3EE), // Cyan
    const Color(0xFF2DD4BF), // Teal
    const Color(0xFF34D399), // Green
    const Color(0xFF4ADE80), // Light green
    const Color(0xFFA3E635), // Lime
    const Color(0xFFF9C463), // Yellow
    const Color(0xFFF3D04F), // Yellow
    const Color(0xFFF39C12), // Orange
    const Color(0xFF7965AE), // Purple
    const Color(0xFFDD8A06), // Orange
    const Color(0xFFD35400), // Orange-red
    const Color(0xFFB24902), // Brown
    const Color(0xFFA63414), // Red-brown
    const Color(0xFF27AE60), // Green
    const Color(0xFF5BC953), // Light green
    const Color(0xFF818CF8), // Purple
    const Color(0xFF9CA66E), // Olive
    const Color(0xFFA8C85B), // Light green
    const Color(0xFF9B882B), // Olive
    const Color(0xFF9C6B1A), // Brown
    const Color(0xFFADB749), // Yellow-green
    const Color(0xFFC94C46), // Red
    const Color(0xFFE879F9), // Pink
    const Color(0xFFE36B67), // Red
    const Color(0xFFF472B6), // Pink
    const Color(0xFFBF6CFF), // Purple
    const Color(0xFFA78BFA), // Purple
    const Color(0xFFC084FC), // Purple
    const Color(0xFF64748B), // Gray
    const Color(0xFF9C59B6), // Purple
    const Color(0xFFA33D8A), // Purple
    const Color(0xFF7268FF), // Blue-purple
  ];

  @override
  void initState() {
    super.initState();
    _iconController.text = '🛍️'; // Default shopping bag icon
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onTypeChanged(int index) {
    setState(() {
      _selectedType = index == 0 ? CategoryType.expense : CategoryType.income;
    });
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _onSave() {
    if (_nameController.text.trim().isNotEmpty && _iconController.text.trim().isNotEmpty) {
      widget.onSave(
        _nameController.text.trim(),
        _iconController.text.trim(),
        _selectedType,
        _selectedColor,
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildColorGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: _colorPalette.length,
        itemBuilder: (context, index) {
          final color = _colorPalette[index];
          final isSelected = color.value == _selectedColor.value;

          return GestureDetector(
            onTap: () => _onColorSelected(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Colors.white,
                        width: 3,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3D4348),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24), // Spacer
                    QuantoText.h3(
                      'New Category',
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.opacity8,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Type selector (Expense/Income)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedToggleSwitch(
                  values: const ['Expense', 'Income'],
                  onToggleCallback: _onTypeChanged,
                ),
              ),
              const SizedBox(height: 24),
              // Icon and name input row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Icon input field
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _iconController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24),
                          maxLength: 2,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            hintText: '🛍️',
                            hintStyle: TextStyle(fontSize: 24),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Category name input
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.opacity8,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Sora',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Category name',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                              fontFamily: 'Sora',
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: GestureDetector(
                              onTap: _onSave,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _onSave(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Color selection grid
              _buildColorGrid(),
              // Bottom padding for safe area
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
