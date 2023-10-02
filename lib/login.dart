import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  String _errorMessage = '';
  // String _successMessage = '';
  String? _email;
  String? _password;
  bool login = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _email = _emailController.text;
      });
    });
    _passwordController.addListener(() {
      setState(() {
        _password = _passwordController.text;
      });
    });
  }

  void _login() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      // UserCredential userCredential =
      await auth.signInWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );
      // _successMessage = ('User: ${userCredential.user}');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          duration: Duration(seconds: 5), // Optional: Set duration
        ),
      );
      if (auth.currentUser!.emailVerified) {
        if (!mounted) {
          return;
        }
        Navigator.pushReplacementNamed(context, '/review');
      } else {
        if (!mounted) {
          return;
        }
        _errorMessage = 'Please verify your email address to continue.';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'A link is sent to your email. Please verify your email address to continue'),
            duration: Duration(seconds: 5), // Optional: Set duration
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Invalid email';
      } else if (e.code == 'user-disabled') {
        _errorMessage = 'User disabled';
      } else if (e.code == 'too-many-requests') {
        _errorMessage = 'Too many requests';
      } else if (e.code == 'operation-not-allowed') {
        _errorMessage = 'Operation not allowed';
      } else if (e.code == 'network-request-failed') {
        _errorMessage = 'Network request failed';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        _errorMessage = 'Invalid login credentials';
      } else {
        _errorMessage = e.code;
      }
    } catch (e) {
      _errorMessage = e.toString();
      // print(e);
    }
    setState(() {});
  }

  void _signup() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: _email!, password: _password!);
      userCredential.user!.sendEmailVerification();
      // if (userCredential.user!.emailVerified) {
      //   if (!mounted) {
      //     return;
      //   }
      //   Navigator.pushReplacementNamed(context, '/review');
      // } else {
      if (!mounted) {
        return;
      }
      // showAboutDialog(
      //   context: context,
      //   applicationName: 'BRL Course Review',
      //   applicationVersion: '1.0.0',
      //   applicationIcon: const Icon(Icons.info),
      //   children: [
      //     const Text(
      //       'Please verify your email address to continue.',
      //     ),
      //   ],
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'A link is sent to your email. Please verify your email address to continue'),
          duration: Duration(seconds: 5), // Optional: Set duration
        ),
      );
      // }
      // print('User: ${userCredential.user}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'The password provided is too weak.';
        // print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // print('The account already exists for that email.');
        _errorMessage = 'The account already exists for that email.';
      }
      setState(() {
        // _errorMessage = e.code;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/review');
    } catch (e) {
      _errorMessage = e.toString();
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                login ? 'Login' : 'Sign Up',
                style: TextStyle(
                  fontSize: 30,
                  // fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.roboto().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                keyboardAppearance: Brightness.dark,
                enableSuggestions: true,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.password],
                keyboardAppearance: Brightness.dark,
                enableSuggestions: false,
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _email != null && _password != null
                    ? login
                        ? _login
                        : _signup
                    : null,
                child: Text(
                  login ? 'Login' : 'Sign Up',
                ),
              ),
              login ? const SizedBox(height: 18) : const SizedBox(height: 0),
              login
                  ? TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?'),
                    )
                  : const SizedBox(height: 0),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    login = !login;
                  });
                },
                child: Text(login ? 'Create Account' : 'Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _googleSignIn,
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
