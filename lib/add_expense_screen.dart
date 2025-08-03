import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String amount = '';
  String selectedCategory = 'Extras';

  final List<Map<String, dynamic>> topButtons = [
    {'label': 'Today', 'icon': Icons.calendar_today},
    {'label': 'Note', 'icon': Icons.note},
  ];

  final List<Map<String, dynamic>> categories = [
    {'label': 'Extras', 'icon': Icons.person, 'selected': true},
    {'label': 'Food', 'icon': Icons.restaurant},
    {'label': 'Groceries', 'icon': Icons.shopping_cart},
    {'label': 'More', 'icon': Icons.more_horiz},
  ];

  void _onNumberPressed(String number) {
    setState(() {
      amount = amount + number;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Amount display with clear button
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      amount.isEmpty ? '0' : amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52.0,
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/svg/Delete.svg',
                          width: 32,
                          height: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            amount = '';
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top buttons (Today, Note)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: topButtons
                    .map((button) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle Today/Note button press
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              icon: Icon(button['icon']),
                              label: Text(button['label']),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

            // Category buttons with More button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(19),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Row(
                  children: [
                    // Scrollable categories
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: categories
                              .where((c) => c['label'] != 'More')
                              .map((category) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selectedCategory = category['label'];
                                    for (var cat in categories) {
                                      cat['selected'] = false;
                                    }
                                    category['selected'] = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: category['selected'] == true
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: const BorderSide(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                icon: Icon(category['icon']),
                                label: Text(category['label']),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // More button (fixed on the right)
                    ...categories
                        .where((c) => c['label'] == 'More')
                        .map((moreButton) {
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle More button press
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: moreButton['selected'] == true
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : Theme.of(context).scaffoldBackgroundColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Icon(Icons.more_horiz, size: 24),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Numeric keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                children: [
                  // First row: 1 2 3
                  Row(
                    children: [
                      _buildNumberButton('1'),
                      _buildNumberButton('2'),
                      _buildNumberButton('3'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Second row: 4 5 6
                  Row(
                    children: [
                      _buildNumberButton('4'),
                      _buildNumberButton('5'),
                      _buildNumberButton('6'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Third row: 7 8 9
                  Row(
                    children: [
                      _buildNumberButton('7'),
                      _buildNumberButton('8'),
                      _buildNumberButton('9'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Fourth row: . 0 Submit
                  Row(
                    children: [
                      _buildNumberButton('.'),
                      _buildNumberButton('0'),
                      _buildSubmitButton(),
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

  Widget _buildNumberButton(String number) {
    return Expanded(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _onNumberPressed(number),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 60),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Expanded(
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Implement expense addition logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4A4A4A),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 60),
          ),
          child: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
