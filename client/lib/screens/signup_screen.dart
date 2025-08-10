import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Transform.translate(
          offset: const Offset(15,10.0),
          child: Image.asset(
            'assets/images/back_button.webp',
            width: 40,
            height: 40,
          ),
        )),
      ),

    );
  }
}