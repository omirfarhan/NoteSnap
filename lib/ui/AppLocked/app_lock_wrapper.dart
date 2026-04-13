import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;
  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _isUnlocked = false;
  bool _isPasswordSet = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

  Future<void> _checkPasswordStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSet = prefs.getBool('isPasswordSet') ?? false;

    setState(() {
      _isPasswordSet = isSet;
      _isChecking = false;
      // যদি password set না থাকে, সরাসরি unlock
      if (!isSet) _isUnlocked = true;
    });

    // Password set থাকলে dialog দেখাও
    if (isSet && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPasswordDialog();
      });
    }
  }

  Future<void> _showPasswordDialog() async {
    final controllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false, // বাইরে tap করলে বন্ধ হবে না
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0D6186),
              title: const Text(
                '🔒 Enter Password',
                style: TextStyle(
                  color: Color(0xFFDBF5FB),
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your 4-digit privacy key',
                    style: TextStyle(
                      color: Color(0xFF9EDDE4),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ৪টা input box
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (i) {
                      return _buildDialogInput(
                        controller: controllers[i],
                        focusNode: focusNodes[i],
                        context: context,
                        isLast: i == 3,
                        onComplete: () async {
                          // ৪ digit পূর্ণ হলে check করো
                          String entered = controllers.map((c) => c.text).join();
                          if (entered.length == 4) {
                            final prefs = await SharedPreferences.getInstance();
                            final saved = prefs.getString('password') ?? '';

                            if (entered == saved) {
                              // ✅ সঠিক password
                              setState(() => _isUnlocked = true);
                              if (context.mounted) Navigator.of(context).pop();
                            } else {
                              // ❌ ভুল password
                              setDialogState(() => error = 'Wrong password! Try again.');
                              for (var c in controllers) c.clear();
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                    () => FocusScope.of(context).requestFocus(focusNodes[0]),
                              );
                            }
                          }
                        },
                        onChanged: (val, i) {
                          if (val.isNotEmpty && i < 3) {
                            FocusScope.of(context).requestFocus(focusNodes[i + 1]);
                          }

                          if (error != null) {
                            setDialogState(() => error = null);
                          }
                        },
                        index: i,
                        focusNodes: focusNodes,
                      );
                    }),
                  ),

                  // Error message
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: const TextStyle(
                        color: Color(0xFFFF2040),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required BuildContext context,
    required bool isLast,
    required VoidCallback onComplete,
    required Function(String, int) onChanged,
    required int index,
    required List<FocusNode> focusNodes,
  }) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF83E3ED), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        //obscureText: true, // password হিসেবে দেখাবে
        textAlign: TextAlign.center,
        cursorColor: const Color(0xFF71CFE4),
        style: const TextStyle(
          fontSize: 22,
          color: Color(0xFFDBF5FB),
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (val) {
          onChanged(val, index);
          if (isLast && val.length == 1) {
            FocusScope.of(context).unfocus();
            onComplete();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFF137FA5),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (!_isUnlocked) {
      return const Scaffold(backgroundColor: Color(0xFF137FA5));
    }
    return widget.child;
  }
}