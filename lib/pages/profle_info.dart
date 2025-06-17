import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Helper to get a user-friendly name from email if displayName is null
  String getUserName(User? user) {
    if (user == null) return 'User Name';
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }
    if (user.email != null && user.email!.contains('@')) {
      final namePart = user.email!.split('@')[0];
      // Capitalize first letter for a cleaner look
      return namePart.isNotEmpty
          ? namePart[0].toUpperCase() + namePart.substring(1)
          : 'User Name';
    }
    return 'User Name';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.account_circle, size: 48, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getUserName(user),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Options row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ProfileOption(icon: Icons.history, label: 'History', onTap: () {/* TODO */}),
                _ProfileOption(icon: Icons.settings, label: 'Settings', onTap: () {/* TODO */}),
                _ProfileOption(icon: Icons.help_outline, label: 'Help', onTap: () {/* TODO */}),
                _ProfileOption(icon: Icons.feedback_outlined, label: 'Feedback', onTap: () {/* TODO */}),
              ],
            ),
            // Add more profile content here if needed
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.teal[50],
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
