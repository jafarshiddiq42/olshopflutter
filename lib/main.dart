import 'package:flutter/material.dart';
import 'package:olshop/screen/auth/login.dart';

void main() {
  runApp(
    MaterialApp(
      home: const Login(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}
