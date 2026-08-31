import '../../../core/utils/navigation_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard/presentation/main_layout.dart';
import 'permissions_onboarding_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _selectedDob;
  String _selectedGender = '';
  bool _dobError = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      _dobError = _selectedDob == null;
    });
    
    if (_formKey.currentState!.validate() && !_dobError) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_nickname', _nicknameController.text.trim());
      if (_selectedDob != null) {
        await prefs.setString('user_dob', _selectedDob!.toIso8601String());
      }
      await prefs.setString('user_gender', _selectedGender);
      await prefs.setString('user_location', _locationController.text.trim());
      

      if (mounted) {
        Navigator.of(context).pushReplacement(
          ModernPageRoute(builder: (_) => const PermissionsOnboardingScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let's Get Started 👋",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tell us a bit about yourself to personalize your experience.",
              ),
              const SizedBox(height: 32),
              
              _buildLabel('Full Name'),
              _buildTextField('Enter your full name', Icons.person_outline, controller: _nameController, isRequired: true),
              
              _buildLabel('Nickname (Optional)'),
              _buildTextField('Enter a nickname', Icons.sentiment_satisfied_alt, controller: _nicknameController),
              
              _buildLabel('Date of Birth'),
              GestureDetector(
                onTap: () {
                  setState(() => _dobError = false);
                  _selectDate(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: _dobError ? Border.all(color: Colors.red.shade400, width: 1.5) : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedDob == null 
                          ? 'Select your date of birth' 
                          : '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: _dobError 
                              ? Colors.red.shade400 
                              : (_selectedDob == null ? Theme.of(context).hintColor : Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.calendar_today, color: _dobError ? Colors.red.shade400 : null),
                    ],
                  ),
                ),
              ),
              if (_dobError)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Text(
                    'Date of birth is required',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                  ),
                ),
              
              _buildLabel('Gender (Optional)'),
              Row(
                children: [
                  _buildGenderChip('Male', Icons.male, Colors.blue),
                  const SizedBox(width: 8),
                  _buildGenderChip('Female', Icons.female, Colors.pink),
                  const SizedBox(width: 8),
                  _buildGenderChip('Other', Icons.transgender, Colors.purple),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildLabel('Location (Optional)'),
              _buildTextField('Enter your city or region', Icons.location_on_outlined, controller: _locationController),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'All data is stored locally on your device.\nWe respect your privacy.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Save & Continue'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 24.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {TextEditingController? controller, bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildGenderChip(String label, IconData icon, Color baseColor) {
    final isSelected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? baseColor.withOpacity(0.2) : Theme.of(context).cardColor,
            border: Border.all(
              color: isSelected ? baseColor : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: baseColor),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
