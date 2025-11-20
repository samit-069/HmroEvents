import 'package:flutter/material.dart';

import 'organizer_main_navigation.dart';

class OrganizerKycAddressPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dob;
  final String citizenshipNumber;

  const OrganizerKycAddressPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.citizenshipNumber,
  });

  @override
  State<OrganizerKycAddressPage> createState() => _OrganizerKycAddressPageState();
}

class _OrganizerKycAddressPageState extends State<OrganizerKycAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _wardController = TextEditingController();
  final _streetController = TextEditingController();

  @override
  void dispose() {
    _provinceController.dispose();
    _districtController.dispose();
    _municipalityController.dispose();
    _wardController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() != true) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OrganizerMainNavigation()),
      (route) => false,
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
                'Step 3 of 3',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Address Verification (Nepal)',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Provide your residential address as per your Nepali citizenship or utility bills.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _provinceController,
                      decoration: const InputDecoration(
                        labelText: 'Province',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Province is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        labelText: 'District',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'District is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _municipalityController,
                      decoration: const InputDecoration(
                        labelText: 'Municipality / Rural Municipality',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Municipality is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _wardController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ward no.',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ward number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street / Tole',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Street / Tole is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        child: const Text(
                          'Submit KYC',
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
