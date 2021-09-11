import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class DrawerNavigationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('assets/imgs/avatar.png'),
            ),
            accountName: Text(
              "Administrador",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text("administrador@adm.com.br"),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/imgs/drawerBackground.jpg"),
                    fit: BoxFit.fill)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text("Empréstimos"),
          ),
          Divider(
            height: 15,
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Mdi.cashPlus),
            title: Text("Novo"),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async => {},
          ),
          ListTile(
            leading: Icon(Icons.list_alt_outlined),
            title: Text("Listar"),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text("Clientes"),
          ),
          Divider(
            height: 15,
            thickness: 2,
          ),
          ListTile(
            leading: Icon(Mdi.accountPlus),
            title: Text("Novo"),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Mdi.accountDetails),
            title: Text("Listar"),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () async {},
          ),
        ],
      ),
    );
  }
}
