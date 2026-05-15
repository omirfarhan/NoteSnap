import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // Current password controllers
  final c0 = TextEditingController();
  final c1 = TextEditingController();
  final c2 = TextEditingController();
  final c3 = TextEditingController();

  // New password controllers
  final n0 = TextEditingController();
  final n1 = TextEditingController();
  final n2 = TextEditingController();
  final n3 = TextEditingController();

  // Confirm new password controllers
  final cf0 = TextEditingController();
  final cf1 = TextEditingController();
  final cf2 = TextEditingController();
  final cf3 = TextEditingController();

  // Security question controllers
  final nicknameController = TextEditingController();
  final colorController = TextEditingController();

  // FocusNodes — current
  final fc0 = FocusNode();
  final fc1 = FocusNode();
  final fc2 = FocusNode();
  final fc3 = FocusNode();

  // FocusNodes — new
  final fn0 = FocusNode();
  final fn1 = FocusNode();
  final fn2 = FocusNode();
  final fn3 = FocusNode();

  // FocusNodes — confirm
  final fcf0 = FocusNode();
  final fcf1 = FocusNode();
  final fcf2 = FocusNode();
  final fcf3 = FocusNode();

  int _step = 0;
  bool _forgotMode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    for (var f in [fc0,fc1,fc2,fc3,fn0,fn1,fn2,fn3,fcf0,fcf1,fcf2,fcf3]) {
      f.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (var c in [c0,c1,c2,c3,n0,n1,n2,n3,cf0,cf1,cf2,cf3,
      nicknameController,colorController]) {
      c.dispose();
    }
    for (var f in [fc0,fc1,fc2,fc3,fn0,fn1,fn2,fn3,fcf0,fcf1,fcf2,fcf3]) {
      f.dispose();
    }
    super.dispose();
  }

  // Step 0: Current password verify
  Future<void> _verifyCurrentPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('password') ?? '';
    final entered = c0.text + c1.text + c2.text + c3.text;

    if (entered == saved) {
      setState(() {
        _step = 1;
        _errorMessage = null;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(fn0);
      });
    } else {
      setState(() => _errorMessage = 'Wrong current password!');
      c0.clear(); c1.clear(); c2.clear(); c3.clear();
      FocusScope.of(context).requestFocus(fc0);
    }
  }

  // Step 1: New password entered → go to confirm
  void _goToConfirm() {
    final newPass = n0.text + n1.text + n2.text + n3.text;
    if (newPass.length == 4) {
      setState(() {
        _step = 2;
        _errorMessage = null;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(fcf0);
      });
    }
  }

  // Step 2: Confirm new password → save
  Future<void> _confirmNewPassword() async {
    final newPass = n0.text + n1.text + n2.text + n3.text;
    final confirmPass = cf0.text + cf1.text + cf2.text + cf3.text;

    if (confirmPass.length == 4) {
      if (newPass == confirmPass) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('password', newPass);
        setState(() {
          _step = 4;
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Passwords do not match!');
        cf0.clear(); cf1.clear(); cf2.clear(); cf3.clear();
        FocusScope.of(context).requestFocus(fcf0);
      }
    }
  }

  // Step 3 (Forgot mode): Security answer verify করে reset
  Future<void> _verifySecurityAndReset() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNickname = prefs.getString('nickname') ?? '';
    final savedColor = prefs.getString('color') ?? '';

    if (nicknameController.text.trim() == savedNickname.trim() &&
        colorController.text.trim() == savedColor.trim()) {
      // ✅ Correct → নতুন password দিতে পাঠাও
      setState(() {
        _step = 1;
        _forgotMode = true;
        _errorMessage = null;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(fn0);
      });
    } else {
      setState(() => _errorMessage = 'Answers do not match!');
    }
  }

  // সব reset করে দাও
  Future<void> _resetAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D6186),
        title: const Text(
          'Reset Everything?',
          style: TextStyle(color: Color(0xFFDBF5FB)),
        ),
        content: const Text(
          'Password and all security answers will be deleted.',
          style: TextStyle(color: Color(0xFF9EDDE4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF9EDDE4))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset',
                style: TextStyle(color: Color(0xFFFF2040))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('password');
      await prefs.remove('nickname');
      await prefs.remove('color');
      await prefs.remove('isPasswordSet');
      await prefs.remove('isAllCompleted');

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D6186),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Color(0xFF0D6186),
        centerTitle: true,
        title: const Text('Change Password',style: TextStyle(
            color: Color(0xFFD9FFFF)
        ),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Color(0xFFD9FFFF)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // ── Step 0: Current password ──
                if (_step == 0) ...[
                  _label('Enter current password'),
                  _pinRow([c0,c1,c2,c3], [fc0,fc1,fc2,fc3],
                      onComplete: _verifyCurrentPassword),
                  const SizedBox(height: 12),

                  // Forgot password button
                  TextButton(
                    onPressed: () {
                      nicknameController.clear();
                      colorController.clear();
                      setState(() {
                        _step = 3;
                        _errorMessage = null;
                      });
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF83E3ED),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                // ── Step 1: New password ──
                if (_step == 1) ...[
                  _label('Enter new password'),
                  _pinRow([n0,n1,n2,n3], [fn0,fn1,fn2,fn3],
                      onComplete: _goToConfirm),
                ],

                // ── Step 2: Confirm new password ──
                if (_step == 2) ...[
                  _label('Confirm new password'),
                  _pinRow([cf0,cf1,cf2,cf3], [fcf0,fcf1,fcf2,fcf3],
                      onComplete: _confirmNewPassword),
                ],

                // ── Step 3: Security questions (forgot mode) ──
                if (_step == 3) ...[
                  _label('Security Questions'),
                  const SizedBox(height: 10),

                  _securityField(nicknameController, 'What is your nickname?'),
                  const SizedBox(height: 10),
                  _securityField(colorController, 'Favorite color?'),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ✅ Verify করে reset
                      ElevatedButton(
                        onPressed: _verifySecurityAndReset,
                        child: const Text('Verify & Reset'),
                      ),

                      // 🔴 সব মুছে দাও
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2040),
                        ),
                        onPressed: _resetAll,
                        child: const Text(
                          'Reset All',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Step 4: সফল ──
                if (_step == 4) ...[
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Password changed successfully!',
                    style: TextStyle(
                      color: Color(0xFFDBF5FB),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFFF2040),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Regular',
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper widgets ──

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFDBF5FB),
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Regular',
        ),
      ),
    );
  }

  Widget _pinRow(
      List<TextEditingController> controllers,
      List<FocusNode> focusNodes, {
        required VoidCallback onComplete,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(4, (i) {
        return _pinBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          isLast: i == 3,
          onComplete: onComplete,
          allFocusNodes: focusNodes,
          index: i,
        );
      }),
    );
  }

  Widget _pinBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isLast,
    required VoidCallback onComplete,
    required List<FocusNode> allFocusNodes,
    required int index,
  }) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: focusNode.hasFocus
              ? const Color(0xFFDBF5FB)
              : const Color(0xFF71CFE4),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: const Color(0xFF71CFE4),
        maxLength: 1,
        //obscureText: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, color: Color(0xFFDBF5FB)),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (isLast) {
              FocusScope.of(context).unfocus();
              onComplete();
            } else {
              FocusScope.of(context).requestFocus(allFocusNodes[index + 1]);
            }
          }
        },
      ),
    );
  }

  Widget _securityField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      cursorColor: const Color(0xFFDBF5FB),
      decoration: InputDecoration(
        hintText: hint,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF83E3ED)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF83E3ED)),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFDBF5FB),
          fontFamily: 'Regular',
          fontSize: 14,
        ),
      ),
      style: const TextStyle(
        color: Color(0xFFDBF5FB),
        fontFamily: 'Regular',
      ),
    );
  }
}