import 'package:flutter/material.dart';
import 'package:inventaris_ukm/models/user.dart';

// ==============================
// ADMIN PAGES
// ==============================
import 'package:inventaris_ukm/pages/admin/admin_dashboard_page.dart';

// ==============================
// USER PAGES
// ==============================
import 'package:inventaris_ukm/pages/user/user_home_page.dart';


// =============================================================
// NAVIGASI BERDASARKAN ROLE USER
// =============================================================
void navigateBasedOnRole(BuildContext context, User user) {
  if (user.role == "admin") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardPage(admin: user),
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UserHomePage(user: user),
      ),
    );
  }
}
