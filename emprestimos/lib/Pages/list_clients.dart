import 'dart:async';

import 'package:emprestimos/Models/client.dart';
import 'package:emprestimos/Utils/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

import 'list_loans.dart';
import 'new_client.dart';
import 'new_loan.dart';

class ListClientsPage extends StatefulWidget {
  static StreamController<List<Client>> clientStreamList =
      StreamController<List<Client>>();

  @override
  _ListClientsPageState createState() => _ListClientsPageState();
}

class _ListClientsPageState extends State<ListClientsPage> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    await SQLiteHelper.instance.listClients().then(
          (clients) => {
            ListClientsPage.clientStreamList.add(clients),
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clientes'),
        actions: [
          IconButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return NewClient();
                  },
                ),
              );
            },
            icon: Icon(Mdi.accountPlus),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: ListClientsPage.clientStreamList.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Client>? clients = snapshot.data as List<Client>?;
            if (clients != null) {
              if (clients.isNotEmpty) {
                return ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Icons.account_box),
                            title: Text('${clients[index].name}'),
                            subtitle: Text(
                              'Nascimento: ${clients[index].birth_date}',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 72, top: 8),
                            child: RichText(
                              text: TextSpan(
                                text: 'CPF: ',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '${clients[index].cpf}\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  TextSpan(text: 'RG: '),
                                  TextSpan(
                                      text: '${clients[index].RG}\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  TextSpan(text: 'Telefone: '),
                                  TextSpan(
                                      text: '${clients[index].tel}\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  TextSpan(text: 'Email: '),
                                  TextSpan(
                                      text: '${clients[index].email}\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  onPrimary:
                                      Theme.of(context).colorScheme.secondary,
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      width: 1),
                                ),
                                onPressed: () async {
                                  await SQLiteHelper.instance
                                      .deleteClient(clients[index].id);
                                  await SQLiteHelper.instance
                                      .listClients()
                                      .then((clients) => {
                                            NewLoan.clientStreamList
                                                .add(clients),
                                            ListClientsPage.clientStreamList
                                                .add(clients),
                                          });
                                  await SQLiteHelper.instance
                                      .listLoansJoin()
                                      .then((loans) => {
                                            ListLoansPage.loanStreamList
                                                .add(loans),
                                          });
                                },
                                child: const Text('Deletar Cliente'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.white,
                                  primary:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return NewClient(
                                          client: clients[index],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text('Atualizar Cadastro'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return Center(child: Text("Nenhum Cliente Cadastrado"));
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    // https://stackoverflow.com/a/56279276
    ListClientsPage.clientStreamList.close();
    ListClientsPage.clientStreamList = StreamController<List<Client>>();
  }
}
