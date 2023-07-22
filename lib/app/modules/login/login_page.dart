import 'package:expenses/app/shared/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/user_authentication_bloc.dart';
import '../../shared/constants/strings.dart';

class LoginUserPage extends StatefulWidget {
  const LoginUserPage({Key? key}) : super(key: key);

  @override
  _LoginUserPageState createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  final authenticationBloc = AuthenticationBloC();
  final loginFormController = GlobalKey<FormState>();
  TextEditingController? emailAddressController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  bool isObscure = true;
  bool wrongPassword = false;
  bool noUserFound = false;

  bool rememberMe = false;
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      email = prefs.getString('email') ?? '';
      emailAddressController!.text = email;
    }
  }

  void _saveRememberMe(bool? value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = value!;
      prefs.setBool('rememberMe', rememberMe);
      if (!rememberMe) {
        email = '';
        prefs.remove('email');
      }
    });
  }

  _saveEmail(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = value;
      prefs.setString('email', email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Container(
            padding: const EdgeInsets.only(left: 35, top: 80),
            child: const Text(
              "My\nExpenses",
              style: TextStyle(color: Colors.white, fontSize: 33),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  right: 35,
                  left: 35,
                  top: MediaQuery.of(context).size.height * 0.5),
              child: Form(
                key: loginFormController,
                child: Column(children: [
                  TextFormField(
                    controller: emailAddressController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (emailAddressController!.text.isEmpty) {
                        return StringConst.emptyEmail;
                      } else if (noUserFound == true) {
                        return StringConst.emailDoesNotExist;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: passwordController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isObscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(
                            () {
                              isObscure = !isObscure;
                            },
                          );
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return StringConst.emptyPassword;
                      } else if (wrongPassword == true) {
                        return StringConst.wrongPassword;
                      }
                      return null;
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Lembrar-me'),
                    value: rememberMe,
                    onChanged: (value) {
                      _saveRememberMe(value);
                    },
                    contentPadding: const EdgeInsets.only(left: 5),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xff4c505b),
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xff4c505b),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: () async {
                            if (loginFormController.currentState!.validate()) {
                              await authenticationBloc.signIn(
                                userEmail: emailAddressController!.text,
                                userPassword: passwordController!.text,
                                noUserFoundError: noUserFound,
                                wrongPasswordError: wrongPassword,
                                context: context,
                                saveEmailFunction: () =>
                                    _saveEmail(emailAddressController!.text),
                              );
                            }
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RoutesConst.register);
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 18,
                              color: Color(0xff4c505b),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 18,
                              color: Color(0xff4c505b),
                            ),
                          ),
                        ),
                      ]),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
