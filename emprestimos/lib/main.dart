import 'package:emprestimos/Pages/list_loans.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFB00020),
        primaryColorDark: Color(0xFF630012),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFB00020),
          secondary: Color(0xFF02B322),
        ),
      ),
      home: ListLoansPage(),
    );
  }
}
