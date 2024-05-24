import 'package:flutter/widgets.dart';

class AppColor{
  Color colorRed = const Color.fromARGB(255, 108, 2, 1);
  Color backgroundColor = const Color.fromARGB(255, 248, 246, 242);

  static const Gradient linerGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 108, 2, 1),
      Color.fromARGB(255, 255, 0, 0),
    ],
    begin: Alignment(0.0,0.0),
    end: Alignment(0.707 , -0.707),
  );
  
}