//@dart=2.9
import 'package:flutter/material.dart';
import 'Measurement.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measurii',
      home: Measurement(),
    );
  }
}.
