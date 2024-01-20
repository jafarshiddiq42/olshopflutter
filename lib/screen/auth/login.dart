import 'package:flutter/material.dart';
import 'package:olshop/network/network.dart';
import 'package:olshop/screen/admin/menu_admin.dart';
import 'package:olshop/screen/auth/register.dart';
import 'package:olshop/screen/user/menu_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn, signUsers }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;

  late String email, password;
  final _key = GlobalKey<FormState>();

  bool _secureText = true;
  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    final response = await http.post(
      Uri.parse(
        NetworkURL.login(),
      ),
      body: {
        "email": email,
        "password": password,
      },
    );
    final data = jsonDecode(response.body);
    int value = data['value'];
    String? pesan = data['message'];
    String? emailAPI = data['email'];
    String? namaAPI = data['nama'];
    String? id = data['id'];
    String? level = data['level'];
    if (value == 1) {
      if (level == "1") {
        setState(() {
          _loginStatus = LoginStatus.signIn;
          savePref(value, emailAPI!, namaAPI!, id!, level!);
        });
      } else {
        setState(() {
          _loginStatus = LoginStatus.signUsers;
          savePref(value, emailAPI!, namaAPI!, id!, level!);
        });
      }
      print(pesan);
    } else {
      print(pesan);
    }
  }

  savePref(
    int value,
    String email,
    String nama,
    String id,
    String level,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("email", email);
      preferences.setString("nama", nama);
      preferences.setString("id", id);
      preferences.setString("level", level);
    });
  }

  dynamic value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getString("level");

      _loginStatus = value == "1"
          ? LoginStatus.signIn
          : value == "2"
              ? LoginStatus.signUsers
              : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.getInt("value") ?? 0;
      preferences.setString("level", "");
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  Future<void> onRefresh() async {
    getPref();
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color.fromARGB(255, 252, 252, 252),
          body: Form(
            key: _key,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    "images/logo.png",
                    height: 150,
                  ),
                  const Text(
                    "Owl Olshop",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 12, 110, 28),
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromRGBO(108, 228, 168, 1),
                                  blurRadius: 10.0,
                                  offset: Offset(0, 5))
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[100]!,
                                    ),
                                  ),
                                ),
                                child: TextFormField(
                                  validator: (e) {
                                    if (e == null || e.isEmpty) {
                                      return "please insert email";
                                    }
                                    return null;
                                  },
                                  onSaved: (e) => email = e!,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "email",
                                    hintStyle: TextStyle(color: Colors.black),
                                    icon: Icon(Icons.person),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  validator: (e) {
                                    if (e == null || e.isEmpty) {
                                      return "please insert password";
                                    }
                                    return null;
                                  },
                                  obscureText: _secureText,
                                  onSaved: (e) => password = e!,
                                  decoration: InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    border: InputBorder.none,
                                    hintText: "Password",
                                    suffixIcon: IconButton(
                                      onPressed: showHide,
                                      icon: Icon(_secureText
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                    ),
                                    hintStyle:
                                        const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 5.0, 0.0, 0.0),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(150.0),
                                  ),
                                  elevation: 18.0,
                                  color: Colors.green[800],
                                  // color: Color(0xFF801E48),
                                  clipBehavior: Clip.antiAlias,
                                  child: MaterialButton(
                                    minWidth: 200.0,
                                    height: 25,
                                    onPressed: () {
                                      check();
                                    },
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Registrasi(getPref),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Belum punya akun?, Daftar disini",
                                  style: TextStyle(color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      case LoginStatus.signIn:
        return MenuAdmin(signOut);
      case LoginStatus.signUsers:
        return MenuUser(signOut);
    }
  }
}
