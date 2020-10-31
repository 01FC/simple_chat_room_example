import 'package:chat_room/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/login_bloc.dart';
import 'form_body.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  LoginBloc _loginBloc;
  bool _showLoading = false;

  void _emailLogIn(bool _) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) {
        return Container(
          padding: MediaQuery.of(context)
              .viewInsets, // mostrar contenido sobre el teclado
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(),
                SizedBox(height: 14),
                TextField(),
                SizedBox(height: 24),
                MaterialButton(
                  onPressed: () {},
                  child: Text("Login"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _googleLogIn(bool _) {
    // invocar al login de firebase con el bloc
    // recodar configurar pantallad Oauth en google Cloud
    print("google");
    _loginBloc.add(LoginWithGoogleEvent());
  }

  void _facebookLogIn(bool _) {
    // invocar al login de firebase con el bloc
    print("facebook");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff0884cc),
                Color(0xff04476e),
              ],
            ),
          ),
        ),
        // form content
        SafeArea(
          child: BlocProvider(
            create: (context) {
              _loginBloc = LoginBloc();
              return _loginBloc..add(VerifyLogInEvent());
            },
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state is LoginErrorState) {
                  _showLoading = false;
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text("${state.error}"),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          )
                        ],
                      );
                    },
                  );
                } else if (state is LoginLoadingState) {
                  _showLoading = !_showLoading;
                }
              },
              builder: (context, state) {
                if (state is LoginSuccessState) {
                  return HomePage();
                }
                return SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Color(0xa0FFffff),
                    ),
                    child: FormBody(
                      onFacebookLoginTap: _facebookLogIn,
                      onGoogleLoginTap: _googleLogIn,
                      onEmailLoginTap: _emailLogIn,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _showLoading ? CircularProgressIndicator() : Container(),
        ),
      ],
    );
  }
}
