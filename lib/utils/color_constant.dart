import 'package:flutter/material.dart';

abstract final class CustomColors {
  static const Color lightBlueColor = Color(0xff88E3FB);
  static const Color lightPurpleColor = Color(0xffE7C6E8);
  static const Color bottomNavText = Color(0xff636363);
  static const Color purpleColor = Color(0xffEEA1F0);
  static const Color blackColor = Color(0xff000000);
  static const Color whiteColor = Color(0xffffffff);
  static const Color silverColor = Color(0xff657296);
  static const Color greyColor = Color(0xffE9E9E9);
  static const Color iconColor = Color(0xffF2F2F2);
  static const Color textGreyColor = Color(0xff494949);
  static const Color textFeildBoaderColor = Color(0xff939393);
  static const Color pinkColor = Color(0xFFD83F87);
  static const Color blueColor = Color(0xFF2480F9);
  static const Color yellow = Color(0xFFFFC72C);
  static const Color darkPurple = Color(0xFF7D69EB);
  static const Color lightBlueBackground = Color(0xffDEF8FF);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: lightBlueColor.withValues(alpha: 0.15),
          blurRadius: 25,
          offset: const Offset(-8, 10),
        ),
        BoxShadow(
          color: darkPurple.withValues(alpha: 0.15),
          blurRadius: 25,
          offset: const Offset(8, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static const LinearGradient purpleBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xff88E3FB), Color(0xffE7C6E8)],
  );

  static LinearGradient blueWhitePurpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xff88E3FB).withValues(alpha: 0.05),
      const Color(0xffFFFFFF),
      const Color(0xffE7C6E8),
    ],
  );
  static LinearGradient whitePurpleGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xffFFF0FF), Color(0xffE7C6E8)],
  );
  static const LinearGradient purpleWhiteBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xffE7C6E8), Color(0xffFFFFFF), Color(0xff88E3FB)],
  );
  static const LinearGradient whiteBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xffFFFFFF),
      Color(0xffFFFFFF),
      Color(0xffFFFFFF),
      Color(0xff88E3FB),
    ],
  );
  static LinearGradient blueWithWhiteGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xffFFFFFF).withValues(alpha: 0.0), // fully transparent
      const Color(0xffFFFFFF).withValues(alpha: 0.8),
      const Color(0xff88E3FB).withValues(alpha: 0.3),
      const Color(0xff88E3FB).withValues(alpha: 0.5),
      const Color(0xff88E3FB).withValues(alpha: 0.5),
      const Color(0xffFFFFFF).withValues(alpha: 0.6),
      const Color(0xffFFFFFF).withValues(alpha: 1.0),
    ],
  );

  static LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xff88E3FB).withValues(alpha: 0.9),
      const Color(0xff2480F9).withValues(alpha: 0.7),
    ],
  );

  static LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xffE7C6E8),
      const Color(0xffD83F87).withValues(alpha: 0.5),
    ],
  );

  static LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.green.withValues(alpha: 0.8),
      Colors.teal.withValues(alpha: 0.6),
    ],
  );

  static LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.orange.withValues(alpha: 0.7),
      Colors.deepOrange.withValues(alpha: 0.5),
    ],
  );

  static LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.teal.withValues(alpha: 0.8),
      Colors.cyan.withValues(alpha: 0.6),
    ],
  );
}
