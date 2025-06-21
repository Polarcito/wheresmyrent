import 'dart:ui';

class Config {
  static const Color backGrounColor = Color(0xFFE0E0E0);
  static const Color primaryColor = Color(0xFFB71C1C); //this is color 900 Colors.red[900]

  static const Color buttonColor = Color(0xFFFBC02D);
  static const Color buttonColorPressed = Color(0xFFB71C1C);
  static const Color buttonTextColorPressed = Color(0xFFFBC02D);
  static const Color progressBarBaseColor = Color(0xFFBDBDBD);
  static const Color textColor1 = Color(0xFFf8fefd);

  static const int maxAdRetries = 3;

  /* TEST */
  static const String adMobBannerId = "ca-app-pub-3940256099942544/6300978111";
  static const String adMobInterstitialId = "ca-app-pub-3940256099942544/1033173712";  

  /* PROD already seted */
  //static const String adMobBannerId = "ca-app-pub-7899443898406196/1767740176";
  //static const String adMobInterstitialId = "ca-app-pub-7899443898406196/4083714659";  
}