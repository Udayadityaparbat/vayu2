// lib/src/ui/screens/auth_screen.dart

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, signup }

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthMode _mode = AuthMode.login;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  late final AnimationController _logoController;
  late final AnimationController _blobController;
  late final Animation<double> _logoScale;
  late final Animation<double> _blobAnim;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);
    Timer(const Duration(milliseconds: 150), () => _logoController.forward());

    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _blobAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _blobController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _logoController.dispose();
    _blobController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    try {
      if (_mode == AuthMode.signup) {
        await prefs.setString('local_email', email);
        await prefs.setString('local_name', name);
        await prefs.setString('local_password', password);
        await prefs.setBool('local_profile_completed', false);
        await prefs.setBool('loggedIn', true);

        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/profile');
      } else {
        final storedEmail = prefs.getString('local_email');
        final storedPass = prefs.getString('local_password');

        if (storedEmail == email && storedPass == password) {
          await prefs.setBool('loggedIn', true);
          final done = prefs.getBool('local_profile_completed') ?? true;
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(done ? '/home' : '/profile');
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incorrect email or password")),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  Widget _animatedBlobs(Size size) {
    return AnimatedBuilder(
      animation: _blobAnim,
      builder: (context, child) {
        final t = _blobAnim.value;
        final left1 = size.width * 0.05 + (20 * (0.5 + 0.5 * (t - 0.5).abs()));
        final top1 = size.height * 0.08 + (30 * (0.5 - (t - 0.5)));
        final right2 = size.width * 0.1 + (50 * (t));
        final bottom2 = size.height * 0.12 + (40 * (1 - t));

        return Stack(children: [
          Positioned(
            left: left1,
            top: top1,
            child: Transform.rotate(
              angle: (t * 2 - 1) * 0.3,
              child: _blob(120, Colors.indigo.shade400.withOpacity(0.18)),
            ),
          ),
          Positioned(
            right: right2,
            bottom: bottom2,
            child: Transform.rotate(
              angle: (t * 2 - 1) * -0.25,
              child: _blob(180, Colors.teal.shade400.withOpacity(0.12)),
            ),
          ),
          Positioned(
            left: size.width * 0.6,
            top: size.height * 0.02 + (30 * t),
            child: Opacity(
              opacity: 0.9 - (0.5 * t),
              child: _blob(80, Colors.blue.shade300.withOpacity(0.10)),
            ),
          )
        ]);
      },
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.4),
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.6)],
          center: const Alignment(-0.3, -0.3),
        ),
      ),
    );
  }

  Widget _glassCard(BuildContext context) {
    final isSignup = _mode == AuthMode.signup;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _mode == AuthMode.login ? 'Welcome back' : 'Create account',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Text(
                      _mode == AuthMode.login ? 'Sign in' : 'Sign up',
                      key: ValueKey(_mode),
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              if (isSignup) ...[
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(label: 'Full name', icon: Icons.person),
                  validator: (v) {
                    if (isSignup && (v == null || v.trim().length < 2)) return 'Please enter name';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(label: 'Email', icon: Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscure,
                decoration: _inputDecoration(
                  label: 'Password',
                  icon: Icons.lock,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) return 'Password must be 6+ chars';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_mode == AuthMode.login ? 'Sign in' : 'Create account'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _mode == AuthMode.login ? 'New here?' : 'Already have an account?',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _toggleMode,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(10, 10)),
                    child: Text(
                      _mode == AuthMode.login ? 'Create account' : 'Sign in',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
                const SizedBox(width: 8),
                Text('or continue with', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _socialButton(Icons.apple, 'Apple')),
                const SizedBox(width: 12),
                Expanded(child: _socialButton(Icons.g_mobiledata, 'Google')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.12))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  // Social buttons are placeholders (no Firebase)
  Widget _socialButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label sign-in not available')),
        );
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.indigo.shade600, Colors.teal.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned.fill(child: _animatedBlobs(size)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.12)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ),

        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    height: 92,
                    width: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Colors.white.withOpacity(0.14), Colors.white.withOpacity(0.06)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset('assets/logo.jpeg', fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Vayu', style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_mode == AuthMode.login ? 'Track and protect your air' : 'Create an account to get started', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 28),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _glassCard(context)),
                const SizedBox(height: 18),
                TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terms & Privacy (TODO)'))), child: Text('Terms & Privacy', style: TextStyle(color: Colors.white.withOpacity(0.6)))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
