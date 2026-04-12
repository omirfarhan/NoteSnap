import 'package:flutter/material.dart';

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
  bool isPasswordMatched = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    focustext.addListener(() => setState(() {}));
    focustext1.addListener(() => setState(() {}));
    focustext2.addListener(() => setState(() {}));
    focustext3.addListener(() => setState(() {}));

    focustext4.addListener(() => setState(() {}));
    focustext5.addListener(() => setState(() {}));
    focustext6.addListener(() => setState(() {}));
    focustext7.addListener(() => setState(() {}));
  }


  void _checkFirstPassword(){
    String firstPass = text.text + text1.text + text2.text + text3.text;
    if(firstPass.length == 4){
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

  void _checkConfirmPassword(){
    String firstPass = text.text + text1.text + text2.text + text3.text;
    String confirmPass = text4.text + text5.text + text6.text + text7.text;

    if(confirmPass.length == 4){

      if(firstPass == confirmPass){
        setState(() {
          errorMessage = null;
          isPasswordMatched = true;
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
            'App Locked'
        ),
      ),


      body: Column(
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
            if (isPasswordMatched)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(height: 40),

                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Password Set Successfully",
                    style: TextStyle(
                      color: Color(0xFFDBF5FB),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            else ...[
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

              // --- Error Message ---
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