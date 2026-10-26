import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class _C {
  // Android 17 style glass (same values as the nav bar and other sheets)
  static const glassTop = Color(0x99262628);
  static const glassBottom = Color(0x8019191A);
  static const field = Color(0x14FFFFFF); // white @ ~8%
  static const text = Color(0xFFF5F5F5);
  static const textSec = Color(0xFFA1A1AA);
  static const textDim = Color(0xFF66666E);
  static const accent = Color(0xFFFFFFFF);
  static const error = Color(0xFFFF7777);
  static const fontFamily = 'inter';
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // Strong blur + slight saturation boost on whatever is behind the page.
  static const List<double> _saturate = [
    1.47244, -0.42912, -0.04332, 0, 0, //
    -0.12756, 1.17088, -0.04332, 0, 0, //
    -0.12756, -0.42912, 1.55668, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  static final ImageFilter _filter = ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ImageFilter.blur(sigmaX: 28, sigmaY: 28, tileMode: TileMode.mirror),
  );

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, String helper) {
    OutlineInputBorder b(Color? c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: c == null ? BorderSide.none : BorderSide(color: c),
    );
    return InputDecoration(
      labelText: label,
      helperText: helper,
      labelStyle: const TextStyle(color: _C.textSec),
      helperStyle: const TextStyle(color: _C.textDim),
      floatingLabelStyle: const TextStyle(color: _C.accent),
      filled: true,
      fillColor: _C.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: b(null),
      enabledBorder: b(null),
      focusedBorder: b(_C.accent),
      errorBorder: b(_C.error),
      focusedErrorBorder: b(_C.error),
      errorStyle: const TextStyle(color: _C.error),
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: save
      // _nameCtrl.text, _phoneCtrl.text, _emailCtrl.text, _passCtrl.text
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No solid color: the glass layer below is the background.
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      // Body goes BEHIND the app bar, so the glass covers the whole sheet
      // (otherwise the app bar area stays empty/transparent with no blur).
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: _C.fontFamily,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: _filter,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_C.glassTop, _C.glassBottom],
                  ),
                ),
              ),
            ),
          ),
          // With extendBodyBehindAppBar the body's top padding already
          // includes the app bar height, so SafeArea pushes the form below it.
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: _C.text),
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter your name'
                              : null,
                          decoration: _dec('Name', 'Enter your name.'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneCtrl,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: _C.text),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _dec('Phone', 'Enter your number.'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailCtrl,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: _C.text),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return null; // optional
                            return t.contains('@') ? null : 'Invalid email';
                          },
                          decoration: _dec('Email', 'Enter your email.'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passCtrl,
                          cursorColor: Colors.white,
                          style: const TextStyle(color: _C.text),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _save(),
                          decoration: _dec('Password', 'Enter your password.'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
