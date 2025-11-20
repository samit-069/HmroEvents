import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'organizer_kyc_documents_page.dart';

class OrganizerKycPersonalPage extends StatefulWidget {
  const OrganizerKycPersonalPage({super.key});

  @override
  State<OrganizerKycPersonalPage> createState() =>
      _OrganizerKycPersonalPageState();
}

class _OrganizerKycPersonalPageState extends State<OrganizerKycPersonalPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _citizenshipController = TextEditingController();

  DateTime? _selectedDob;
  bool _loadingUser = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserBasic();
  }

  Future<void> _loadCurrentUserBasic() async {
    setState(() => _loadingUser = true);
    final res = await AuthService.getCurrentUser();
    if (!mounted) return;

    if (res['success'] == true && res['user'] != null) {
      final u = res['user'] as Map<String, dynamic>;
      _firstNameController.text = (u['firstName'] ?? '').toString();
      _lastNameController.text = (u['lastName'] ?? '').toString();
      _emailController.text = (u['email'] ?? '').toString();
      _phoneController.text = (u['phone'] ?? '').toString();
    }

    setState(() => _loadingUser = false);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _citizenshipController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() != true) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerKycDocumentsPage(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dob: _dobController.text.trim(),
          citizenshipNumber: _citizenshipController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer KYC'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 1 of 3',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Provide your legal details as per your Nepali citizenship.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_loadingUser)
                const Center(child: CircularProgressIndicator())
              else
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration:
                            const InputDecoration(labelText: 'First name'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lastNameController,
                        decoration:
                            const InputDecoration(labelText: 'Last name'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) {
                            return 'Email is required';
                          }
                          // Simple, reliable email validation
                          final emailRegex = RegExp(
                              r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
                          if (!emailRegex.hasMatch(v)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile number (Nepal)',
                          hintText: '98XXXXXXXX',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Mobile number is required';
                          }
                          final digits =
                              v.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length != 10 || !digits.startsWith('98')) {
                            return 'Enter a valid Nepali mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        onTap: _pickDob,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Date of birth is required'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _citizenshipController,
                        decoration: const InputDecoration(
                          labelText: 'Citizenship number (Nepal)',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Citizenship number is required'
                                : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleContinue,
                          child: const Text(
                            'Continue to Documents',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}