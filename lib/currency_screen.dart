import 'package:flutter/material.dart';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/services/currency_service.dart';
import 'package:expense_app/widgets/setting_item.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String? selectedCurrency;
  bool _isLoading = true;
  late final List<Map<String, String>> mostUsedCurrencies;
  late final List<Map<String, String>> allCurrencies;

  @override
  void initState() {
    super.initState();

    // Initialize currency lists
    mostUsedCurrencies = [
      {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸'},
      {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺'},
      {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺'},
    ];

    allCurrencies = [
      {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸'},
      {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺'},
      {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧'},
      {'code': 'JPY', 'name': 'Japanese Yen', 'flag': '🇯🇵'},
      {'code': 'AUD', 'name': 'Australian Dollar', 'flag': '🇦🇺'},
      // Add more currencies as needed
    ];

    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    try {
      final currency = await CurrencyService.getSelectedCurrency();
      if (mounted) {
        setState(() {
          selectedCurrency = currency;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Save the selected currency when back is pressed
        if (selectedCurrency != null) {
          await CurrencyService.setSelectedCurrency(selectedCurrency!);
        }
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    // Filter out most used currencies from all currencies
    final otherCurrencies = allCurrencies
        .where(
            (c) => !mostUsedCurrencies.any((muc) => muc['code'] == c['code']))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Select Currency',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sora'),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, selectedCurrency),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search currency',
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Most Used Currencies Section
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text(
                  'Most Used Currencies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mostUsedCurrencies.length,
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 1,
                    color: const Color(0xFF3A3A3A),
                  ),
                  itemBuilder: (context, index) {
                    final currency = mostUsedCurrencies[index];
                    final isSelected = currency['code'] == selectedCurrency;

                    return SettingItem(
                      title: '${currency['code']} - ${currency['name']}',
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          currency['flag']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      textColor: Colors.white,
                      onTap: () async {
                        setState(() => _isLoading = true);
                        try {
                          await CurrencyService.setSelectedCurrency(
                              currency['code']!);
                          if (mounted) {
                            setState(() {
                              selectedCurrency = currency['code'];
                              _isLoading = false;
                            });
                          }
                        } catch (e) {
                          // Error selecting currency
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                      showTrailingArrow: false,
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFFD0FD3E),
                              size: 20,
                            )
                          : null,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // All Other Currencies Section
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text(
                  'All Currencies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sora',
                  ),
                ),
              ),
              _buildCurrencyList(otherCurrencies),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyList(List<Map<String, String>> currencies) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currencies.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final currency = currencies[index];
        final isSelected = currency['code'] == selectedCurrency;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isSelected ? const Color(0xFFD0FD3E) : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                setState(() => _isLoading = true);
                try {
                  await CurrencyService.setSelectedCurrency(currency['code']!);
                  if (mounted) {
                    setState(() {
                      selectedCurrency = currency['code'];
                      _isLoading = false;
                    });
                  }
                } catch (e) {
                  // Error selecting currency
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    // Flag
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3A),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        currency['flag']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Currency Code and Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency['code']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Sora',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currency['name']!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Checkmark if selected
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFFD0FD3E),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
