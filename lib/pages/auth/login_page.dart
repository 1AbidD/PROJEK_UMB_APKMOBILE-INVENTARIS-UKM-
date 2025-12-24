import 'package:flutter/material.dart';
import 'package:inventaris_ukm/models/user.dart';
import 'package:inventaris_ukm/services/auth_service.dart';
import 'package:inventaris_ukm/services/navigation_helper.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // ====== PROSES LOGIN ======
    User? user = await AuthService.instance.login(
      _usernameC.text.trim(),
      _passwordC.text.trim(),
    );

    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username atau password salah")),
      );
    } else {
      // ====== NAVIGASI BERDASARKAN ROLE ======
      navigateBasedOnRole(context, user);
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ================= LOGO =================
                Image.asset(
                  'assets/icon/logoUkm.png', // Sesuaikan path logo Anda
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),

                const Text(
                  "Inventaris UKM Sport",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // ================= CARD LOGIN =================
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameC,
                            decoration: const InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Isi username" : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _passwordC,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Isi password" : null,
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              child: _loading
                                  ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )
                                  : const Text("Login"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/register'),
                  child: const Text("Belum punya akun? Daftar di sini"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}