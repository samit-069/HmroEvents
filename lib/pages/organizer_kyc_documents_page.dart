import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'organizer_kyc_address_page.dart';

class OrganizerKycDocumentsPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dob;
  final String citizenshipNumber;

  const OrganizerKycDocumentsPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.citizenshipNumber,
  });

  @override
  State<OrganizerKycDocumentsPage> createState() => _OrganizerKycDocumentsPageState();
}

class _OrganizerKycDocumentsPageState extends State<OrganizerKycDocumentsPage> {
  final ImagePicker _picker = ImagePicker();

  File? _frontIdImage;
  File? _backIdImage;
  File? _selfieWithIdImage;
  File? _ppPhotoImage;

  Future<void> _pickImage(String type) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      final file = File(picked.path);
      switch (type) {
        case 'front':
          _frontIdImage = file;
          break;
        case 'back':
          _backIdImage = file;
          break;
        case 'selfie':
          _selfieWithIdImage = file;
          break;
        case 'pp':
          _ppPhotoImage = file;
          break;
      }
    });
  }

  void _handleContinue() {
    if (_frontIdImage == null ||
        _backIdImage == null ||
        _selfieWithIdImage == null ||
        _ppPhotoImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents before continuing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerKycAddressPage(
          firstName: widget.firstName,
          lastName: widget.lastName,
          email: widget.email,
          phone: widget.phone,
          dob: widget.dob,
          citizenshipNumber: widget.citizenshipNumber,
        ),
      ),
    );
  }

  Widget _buildDocTile({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onChoose,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onChoose,
            child: const Text('Choose'),
          ),
        ],
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
                'Step 2 of 3',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Identification Documents',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Upload clear photos of your Nepali citizenship or ID. All four documents are required.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildDocTile(
                title: 'Citizenship / ID - Front',
                subtitle: 'Front side of your Nepali citizenship or national ID.',
                image: _frontIdImage,
                onChoose: () => _pickImage('front'),
              ),
              _buildDocTile(
                title: 'Citizenship / ID - Back',
                subtitle: 'Back side of your Nepali citizenship or national ID.',
                image: _backIdImage,
                onChoose: () => _pickImage('back'),
              ),
              _buildDocTile(
                title: 'Selfie with ID',
                subtitle: 'Your face clearly visible while holding the same ID.',
                image: _selfieWithIdImage,
                onChoose: () => _pickImage('selfie'),
              ),
              _buildDocTile(
                title: 'Passport-size Photo',
                subtitle: 'Recent passport-size photograph (PP size).',
                image: _ppPhotoImage,
                onChoose: () => _pickImage('pp'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  child: const Text('Continue to Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
