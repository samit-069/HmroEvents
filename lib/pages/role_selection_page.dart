import 'package:flutter/material.dart';
import '../signup_page.dart';
import '../models/user_role.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _handleRoleSelection(BuildContext context, UserRole role) {
    RoleSelectionState.instance.setRole(role);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Title with arrow and star
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Choose your role below',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_downward,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: Colors.lightBlue[300],
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                // Organizer Card (First)
                _buildRoleCard(
                  context: context,
                  title: 'Organizer',
                  icon: Icons.event,
                  onTap: () => _handleRoleSelection(context, UserRole.organizer),
                  isFirst: true,
                ),
                const SizedBox(height: 20),
                // "or" separator
                Text(
                  'or',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                // User Card (Second)
                _buildRoleCard(
                  context: context,
                  title: 'User',
                  icon: Icons.person,
                  onTap: () => _handleRoleSelection(context, UserRole.user),
                  isFirst: false,
                ),
                const SizedBox(height: 40),
                // Back button with arrow and star
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: -20,
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: -5,
                      child: Icon(
                        Icons.star,
                        color: Colors.pink[300],
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isFirst,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7), // Purple background
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Person illustration/Icon on left
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Person body
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Icon overlay
                      Icon(
                        icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Title on right
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Decorative stars
        if (isFirst) ...[
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.star,
              color: Colors.purple[200],
              size: 20,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Icon(
              Icons.star,
              color: Colors.green[300],
              size: 20,
            ),
          ),
        ] else ...[
          Positioned(
            bottom: 8,
            left: 8,
            child: Icon(
              Icons.star,
              color: Colors.purple[200],
              size: 20,
            ),
          ),
        ],
      ],
    );
  }
}

