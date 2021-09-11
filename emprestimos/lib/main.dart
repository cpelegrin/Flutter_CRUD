import 'package:flutter/material.dart';

import 'Pages/new_client.dart';
import 'Widgets/drawer_navigation_widget.dart';

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
        accentColor: Color(0xFF02B322),
      ),
      home: NewClient(),
      // routes: {
      //   '/': (context) => const FirstScreen(),
      //   '/second': (context) => const SecondScreen(),
      // },
    );
  }
}

/**
 * cadastro de clientes (simples)
 * cadastro de Emprestimos (simples)
 *
 * Conforme os requisitos acima, é necessário uma lista de clientes e outra de cadastros.
 * A homepage deverá mostrar a lista de empréstimos organizada por data, do menor para o maior.
 *
 * Incluir Drawer Navigation com as funcionalidades
 *
 * Inlcuior navegação por rota nomeada
 */
class LoanList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empréstimos'),
      ),
      drawer: SafeArea(
        child: DrawerNavigationWidget(),
      ),
      body: Container(),
    );
  }
}
