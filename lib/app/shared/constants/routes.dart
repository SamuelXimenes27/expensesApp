import 'package:expenses/app/app_widget.dart';
import 'package:expenses/app/modules/selectUser/login_page.dart';
import 'package:expenses/app/modules/selectUser/register_page.dart';
import 'package:flutter/material.dart';

class RoutesConst {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AppPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = 0.0;
            var end = 1.0;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
        );
      case login:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginUserPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case register:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const RegisterUserPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      // default:
      // return MaterialPageRoute(builder: (_) => ErrorPage());
    }
    throw {debugPrint('Erro nas rotas')};
  }
}
