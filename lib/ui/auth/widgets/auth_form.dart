import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../constants/firebase_constants.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;

  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'username': '',
    'password': '',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    try {
      Focus.of(context).unfocus();
    } catch (_) {}
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    await _submitAuthData(
        _authData['email']!.trim(),
        _authData['username']!.trim(),
        _authData['password']!.trim(),
        _authMode == AuthMode.Login ? true : false);

    print('after submission');
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  Future<void> _submitAuthData(
      String email, String username, String password, bool isLogin) async {
    try {
      if (isLogin) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        final _authResult = await firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_authResult.user!.uid)
            .set({
          'username': username,
          'email': email,
        });
      }
    } on FirebaseAuthException catch (e) {
      var errorMessage =
          e.message ?? 'Error occurred, please check your credentials!';
      print(errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
        backgroundColor: Theme.of(context).errorColor,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$error'),
        backgroundColor: Theme.of(context).errorColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Center(
      child: Card(
        // color: Theme.of(context).accentColor,
        margin: const EdgeInsets.all(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // curve: Curves.easeIn,
          height: _authMode == AuthMode.Signup ? 430 : 300,
          width: deviceSize.width * 0.8,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _authMode == AuthMode.Signup
                          ? TextFormField(
                              key: const ValueKey('username'),
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 5) {
                                  return 'Please enter at-least 5 characters';
                                }
                              },
                              onSaved: (value) {
                                _authData['username'] = value!;
                              },
                            )
                          : Container(),
                    ),
                    TextFormField(
                      key: const ValueKey('email'),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                      ),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Invalid email!';
                        }
                      },
                      onSaved: (value) {
                        _authData['email'] = value!;
                      },
                    ),
                    TextFormField(
                      key: const ValueKey('password'),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Password is too short!';
                        }
                      },
                      onSaved: (value) {
                        _authData['password'] = value!;
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        child: Text(
                          _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                        ),
                        onPressed: _submit,
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(15.0)),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white)),
                      ),
                    TextButton(
                      child: Text(
                        _authMode == AuthMode.Login
                            ? 'Create new account'
                            : 'Have an account? Login',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: _isLoading ? null : _switchAuthMode,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
