import 'package:flutter/material.dart';
import 'package:inventaris_ukm/models/user.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  String formatDate(String? iso) {
    if (iso == null) return "-";
    return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(iso));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: const Icon(Icons.person, size: 40),
                  ),
                ),
                const SizedBox(height: 20),

                _item("Username", user.username),
                _item("Role", user.role),
                _item("Status", user.approved == 1 ? "Aktif" : "Pending"),
                _item("Dibuat Pada", formatDate(user.createdAt)),

                const SizedBox(height: 20),

                // Logout button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
