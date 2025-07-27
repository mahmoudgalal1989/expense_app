import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:expense_app/services/chart_service.dart';
import 'package:expense_app/services/notification_service.dart';

// Base onboarding page widget
class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget image;
  final Widget? extraContent;
  final bool showBackButton;
  final bool isLastPage;
  final VoidCallback? onNextPressed;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSkipPressed;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    this.extraContent,
    this.showBackButton = false,
    this.isLastPage = false,
    this.onNextPressed,
    this.onBackPressed,
    this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            // Image/Illustration
            Expanded(
              child: Center(
                child: image,
              ),
            ),
            // Extra content (charts, lists, etc.)
            if (extraContent != null) extraContent!,
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Onboarding Page 1: Track Income & Expenses
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'emoji': '🍔', 'name': 'Food', 'amount': '\$120.00'},
      {'emoji': '🚕', 'name': 'Transport', 'amount': '\$45.50'},
      {'emoji': '🏠', 'name': 'Rent', 'amount': '\$800.00'},
      {'emoji': '🛒', 'name': 'Groceries', 'amount': '\$95.30'},
      {'emoji': '🎮', 'name': 'Entertainment', 'amount': '\$32.00'},
    ];

    return OnboardingPage(
      title: 'Track income & expenses',
      subtitle: 'Log your expenses and income in seconds...',
      image: SvgPicture.asset(
        'assets/illustrations/onboarding1.svg',
        width: 250,
      ),
      extraContent: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ...categories.map((category) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category['emoji'],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          category['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        category['amount'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF044C85),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// Onboarding Page 2: Set a Reminder
class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> {
  final NotificationService _notificationService = NotificationService();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 21, minute: 0); // Default to 9 PM
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initReminderTime();
  }

  Future<void> _initReminderTime() async {
    await _notificationService.initialize();
    final time = await _notificationService.getReminderTime();
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF044C85),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      await _notificationService.scheduleDailyReminder(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return OnboardingPage(
      title: 'Set a reminder?',
      subtitle:
          'Daily reminders helped 46% of our users stay on track with their budget goals.',
      image: SvgPicture.asset(
        'assets/illustrations/onboarding2.svg',
        width: 250,
      ),
      extraContent: Column(
        children: [
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none, color: Color(0xFF044C85)),
                  const SizedBox(width: 8),
                  Text(
                    'Daily at ${_selectedTime.format(context)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF044C85),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 16, color: Color(0xFF044C85)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can change this anytime in settings',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Onboarding Page 3: Understand Your Spending
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      title: 'Understand your spending',
      subtitle: 'Analyze your breakdowns and see where your money goes each month.',
      image: const SizedBox(height: 16), // Reduce space since chart takes more vertical space
      extraContent: Container(
        margin: const EdgeInsets.only(top: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Donut chart
            SizedBox(
              height: 200,
              child: ChartService.buildDonutChart(),
            ),
            const SizedBox(height: 16),
            // Category legends
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 8,
              children: ChartService.getCategoryLegends(),
            ),
          ],
        ),
      ),
    );
  }
}

// Onboarding Page 4: Spot Patterns
class OnboardingPage4 extends StatelessWidget {
  const OnboardingPage4({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      title: 'Spot patterns, stay in control',
      subtitle: 'Visualize your daily spending trends and identify areas to save.',
      image: const SizedBox(height: 16), // Reduce space since chart takes more vertical space
      extraContent: Container(
        margin: const EdgeInsets.only(top: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Bar chart
            SizedBox(
              height: 200,
              child: ChartService.buildBarChart(),
            ),
            const SizedBox(height: 16),
            // Summary text
            const Text(
              'Track your spending patterns and identify opportunities to save more each week.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
