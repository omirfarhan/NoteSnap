import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {

  TextEditingController text = TextEditingController();
  TextEditingController text1 = TextEditingController();
  TextEditingController text2 = TextEditingController();
  TextEditingController text3 = TextEditingController();

  TextEditingController text4 = TextEditingController();
  TextEditingController text5 = TextEditingController();
  TextEditingController text6 = TextEditingController();
  TextEditingController text7 = TextEditingController();

  TextEditingController nicknameController = TextEditingController();
  TextEditingController colorController = TextEditingController();

  final focustext = FocusNode();
  final focustext1 = FocusNode();
  final focustext2 = FocusNode();
  final focustext3 = FocusNode();

  final focustext4 = FocusNode();
  final focustext5 = FocusNode();
  final focustext6 = FocusNode();
  final focustext7 = FocusNode();

  bool showConfirmRow = false;
  bool isFirstStepDone = false;


  bool showSecurityQuestion = false;
  bool isAllCompleted = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();

    focustext.addListener(() => setState(() {}));
    focustext1.addListener(() => setState(() {}));
    focustext2.addListener(() => setState(() {}));
    focustext3.addListener(() => setState(() {}));

    focustext4.addListener(() => setState(() {}));
    focustext5.addListener(() => setState(() {}));
    focustext6.addListener(() => setState(() {}));
    focustext7.addListener(() => setState(() {}));
  }

  Future<void> _saveData()async{
    final prefs=await SharedPreferences.getInstance();
    String password = text.text + text1.text + text2.text + text3.text;

    await prefs.setString('password', password);
    await prefs.setString('nickname', nicknameController.text);
    await prefs.setString('color', colorController.text);
    await prefs.setBool('isPasswordSet', true);
    await prefs.setBool('isAllCompleted', true);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSet = prefs.getBool('isPasswordSet') ?? false;
    bool completed = prefs.getBool('isAllCompleted') ?? false;

    if(isSet){
      setState(() {
        isFirstStepDone = true;
        showConfirmRow = true;
        showSecurityQuestion = false;
        isAllCompleted = completed;
      });
    }
  }

  Future<void> _checkSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    String savedPass = prefs.getString('password') ?? '';
    String enteredPass = text.text + text1.text + text2.text + text3.text;

    if(enteredPass == savedPass){
      print("Access granted");
      // Navigator.pushReplacement(...)
    }else{
      setState(() {
        errorMessage = "Wrong password!";
      });
      print("Access denied");
      text.clear();
      text1.clear();
      text2.clear();
      text3.clear();

      FocusScope.of(context).requestFocus(focustext);
    }
  }

  Future<void> _checkFirstPassword() async {
    final prefs = await SharedPreferences.getInstance();
    bool isSet = prefs.getBool('isPasswordSet') ?? false;

    String firstPass = text.text + text1.text + text2.text + text3.text;
    if(firstPass.length == 4){

      if(isSet){
        // 👉 already password set → login mode
        _checkSavedPassword();
      }else{
        // 👉 first time setup
        setState(() {
          showConfirmRow = true;
          isFirstStepDone = true;
          errorMessage = null;
        });

        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(focustext4);
        });
      }
    }
  }

  void _checkConfirmPassword(){
    String firstPass = text.text + text1.text + text2.text + text3.text;
    String confirmPass = text4.text + text5.text + text6.text + text7.text;

    if(confirmPass.length == 4){

      if(firstPass == confirmPass){
        setState(() {
          errorMessage = null;
          showSecurityQuestion = true;
        });
        print('Password confirmed: $confirmPass');
      }else{
        setState(() {
          errorMessage = 'Wrong password! Please try again.';
        });

        text4.clear();
        text5.clear();
        text6.clear();
        text7.clear();

        Future.delayed(Duration(milliseconds: 100),() {
          FocusScope.of(context).requestFocus(focustext4);
        });

      }


    }

  }

  void _submitSecurityAnswer()async{
    if(nicknameController.text.length < 4 || colorController.text.length < 4){
      setState(() {
        errorMessage = "Each answer must be at least 4 characters";
      });
      return;
    }
    await _saveData();

    setState(() {
      errorMessage = null;
      isAllCompleted = true;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D6186),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Color(0xFF0D6186),
        centerTitle: true,

        title: const Text(
            'App Locked',style: TextStyle(
            color: Color(0xFFD9FFFF)
        ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Color(0xFFD9FFFF)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),


      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),

            if(!isFirstStepDone)...[
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Please enter your privacy key',
                  style: TextStyle(
                      fontFamily: 'Regular',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFFDBF5FB)
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    myinputBox(context, text, focustext),
                    myinputBox(context, text1, focustext1),
                    myinputBox(context, text2, focustext2),
                    myinputBox(
                        context,
                        text3,
                        focustext3,
                        isLastOfRow: true,
                        onRowComplete: _checkFirstPassword
                    ),
                  ],
                ),
              ),
            ],

            if (showConfirmRow) ...[
              if (isAllCompleted)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Password set successfully",
                        style: TextStyle(
                          color: Color(0xFFDBF5FB),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Regular',
                        ),
                      ),
                    ],
                  ),
                )
                else if(showSecurityQuestion) ...[

                  Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Security Questions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDBF5FB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                      children: [
                        TextField(
                          controller: nicknameController,
                          cursorColor: Color(0xFFDBF5FB),
                          decoration: InputDecoration(
                            hintText: "What is your nickname?",

                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF83E3ED)),
                            ),

                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF83E3ED)),
                            ),
                            hintStyle: TextStyle(
                              color: Color(0xFFDBF5FB),
                              fontFamily: 'Regular',
                              fontSize: 14
                            ),

                          ),
                          style: TextStyle(
                            color: Color(0xFFDBF5FB),
                            fontFamily: 'Regular',
                          ),

                        ),

                        SizedBox(height: 10),

                        TextField(
                          cursorColor: Color(0xFFDBF5FB),
                          controller: colorController,
                          decoration: InputDecoration(
                            hintText: "Favorite color?",

                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF83E3ED)),
                              ),

                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF83E3ED)),
                              ),
                              hintStyle: TextStyle(
                                color: Color(0xFFDBF5FB),
                                fontFamily: 'Regular',
                                  fontSize: 14
                              )
                          ),

                          style: TextStyle(
                            color: Color(0xFFDBF5FB),
                            fontFamily: 'Regular',
                          ),
                        ),
                        SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _submitSecurityAnswer,
                          child: Text("Submit"),
                        ),


                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color:  Color(0xFFFF2040),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Regular',
                              ),
                            ),
                          ),
                      ],
                  ),
                )


              ] else ...[
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Please confirm your privacy key',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFFDBF5FB),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      myinputBox(context, text4, focustext4),
                      myinputBox(context, text5, focustext5),
                      myinputBox(context, text6, focustext6),
                      myinputBox(
                        context,
                        text7,
                        focustext7,
                        isLastOfRow: true,
                        onRowComplete: _checkConfirmPassword,
                      ),
                    ],
                  ),
                ),


                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Color(0xFFFF2040),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ],
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget myinputBox(
      BuildContext context,
      TextEditingController controller,
      FocusNode focusnode,{

        bool isFirst=false,
        isLastOfRow = false,
        VoidCallback? onRowComplete,

    }) {
    
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          border: Border.all(width: 1,
            color: focusnode.hasFocus
                ? Color(0xFFDBF5FB)
                : Color(0xFF71CFE4),
          ),
          borderRadius: BorderRadius.all(
              Radius.circular(20)
          )
      ),
      child: TextField(
        controller: controller,
        focusNode: focusnode,
        cursorColor: Color(0xFF71CFE4),
        maxLength: 1,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 22,
          color: Color(0xFFDBF5FB),
        ),
        decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none
        ),

        textAlign: TextAlign.center,
        onChanged: (value) {
          if (value.length == 1) {
            if(isLastOfRow){
              FocusScope.of(context).unfocus();
              onRowComplete?.call();
            }else{
              FocusScope.of(context).nextFocus();
            }

          }
        },
      ),
    );
  }





}