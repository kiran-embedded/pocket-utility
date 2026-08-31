import 'package:flutter/material.dart';
import '../../../../core/utils/navigation_utils.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime? _dob;
  
  int _years = 0;
  int _months = 0;
  int _days = 0;
  int _nextBirthdayMonths = 0;
  int _nextBirthdayDays = 0;
  int _totalDays = 0;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: Theme.of(context).primaryColor,
                    surface: Theme.of(context).cardColor,
                  )
                : ColorScheme.light(
                    primary: Theme.of(context).primaryColor,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
        _calculateAge();
      });
    }
  }

  void _calculateAge() {
    if (_dob == null) return;
    
    DateTime now = DateTime.now();
    _totalDays = now.difference(_dob!).inDays;
    
    _years = now.year - _dob!.year;
    _months = now.month - _dob!.month;
    _days = now.day - _dob!.day;

    if (_months < 0 || (_months == 0 && _days < 0)) {
      _years--;
      _months += (_months < 0 ? 12 : 11);
    }
    
    if (_days < 0) {
      final previousMonth = DateTime(now.year, now.month, 0);
      _days += previousMonth.day;
    }

    // Next birthday
    DateTime nextBirthday = DateTime(now.year, _dob!.month, _dob!.day);
    if (nextBirthday.isBefore(now) || nextBirthday.isAtSameMomentAs(now)) {
      nextBirthday = DateTime(now.year + 1, _dob!.month, _dob!.day);
    }
    
    _nextBirthdayMonths = nextBirthday.month - now.month;
    _nextBirthdayDays = nextBirthday.day - now.day;
    
    if (_nextBirthdayDays < 0) {
      _nextBirthdayMonths--;
      final previousMonth = DateTime(nextBirthday.year, nextBirthday.month, 0);
      _nextBirthdayDays += previousMonth.day;
    }
    if (_nextBirthdayMonths < 0) {
      _nextBirthdayMonths += 12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert), 
            onPressed: () => NavigationUtils.showGlobalMoreOptions(context),
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date of Birth', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          _dob == null ? 'Select Date' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _dob == null ? Colors.grey : null),
                        ),
                      ],
                    ),
                    Icon(Icons.calendar_month, color: primaryColor, size: 40),
                  ],
                ),
              ),
            ),
            
            if (_dob != null) ...[
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('YOUR AGE IS', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _buildAgeBlock('$_years', 'Years'),
                        _buildAgeBlock('$_months', 'Months'),
                        _buildAgeBlock('$_days', 'Days'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Next Birthday',
                      '$_nextBirthdayMonths months\n$_nextBirthdayDays days',
                      Icons.cake,
                      Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      'Total Days',
                      '$_totalDays\ndays old',
                      Icons.favorite,
                      Colors.redAccent,
                    ),
                  ),
                ],
              )
            ] else ...[
              const SizedBox(height: 100),
              Icon(Icons.cake_outlined, size: 100, color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 24),
              const Text('Please select your date of birth', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildAgeBlock(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
        ],
      ),
    );
  }
}
