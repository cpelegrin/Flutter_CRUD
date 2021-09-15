import 'dart:async';
import 'dart:convert' as convert;

import 'package:brasil_fields/brasil_fields.dart';
import 'package:emprestimos/Models/client.dart';
import 'package:emprestimos/Models/loan.dart';
import 'package:emprestimos/Pages/new_client.dart';
import 'package:emprestimos/Utils/connection_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mdi/mdi.dart';
import 'package:http/http.dart' as http;

import '../Utils/sqlite_helper.dart';
import 'list_loans.dart';

class NewLoan extends StatefulWidget {
  static StreamController<List<Client>> clientStreamList =
      StreamController<List<Client>>();

  @override
  State<NewLoan> createState() => _NewLoanState();
}

class _NewLoanState extends State<NewLoan> {
  final _formKey = GlobalKey<FormState>();

  final _tValor = TextEditingController();
  final _tVencimento = TextEditingController();
  final _tTaxa = TextEditingController();

  final _fVencimento = FocusNode();
  final _fTaxa = FocusNode();

  String? _clientDropdownValue;
  String? _currencySymbolDropdownValue;

  Map<String, String>? _currencyData = {};

  @override
  void initState() {
    _getInitialData();
    super.initState();
  }

  _getInitialData() async {
    if (await ConnectionStatus.testarConexao() != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problemas na conexão')),
      );
    } else {
      var url = Uri.parse(
          "https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/Moedas?\$top=100&\$format=json");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        jsonResponse['value'].forEach((currency) {
          _currencyData!
              .addAll({currency['simbolo']: currency['nomeFormatado']});
        });
      } else {
        print(response.statusCode);
      }
      await SQLiteHelper.instance.listClients().then(
            (clients) => {
              NewLoan.clientStreamList.add(clients),
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Empréstimo'),
        actions: [
          IconButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              FocusScope.of(context).unfocus();
              _save(context);
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: StreamBuilder<List<Client>>(
        stream: NewLoan.clientStreamList.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Nenhum Cliente Cadastrado!"),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return NewClient();
                                },
                              ),
                            );
                          },
                          child: Text("Cadastrar"))
                    ],
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Icon(
                                      Icons.person_add,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _clientDropdownValue,
                                      style: TextStyle(color: Colors.grey[600]),
                                      items:
                                          snapshot.data!.map((Client client) {
                                        return DropdownMenuItem<String>(
                                          value: client.id.toString(),
                                          child: Text("${client.name}"),
                                        );
                                      }).toList(),
                                      hint: Text(
                                        "Selecione um Cliente",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _clientDropdownValue = value;
                                        });
                                      },
                                      validator: (String? value) {
                                        if (value == null) {
                                          return "Selecione um Cliente";
                                        }
                                        if (value.isEmpty) {
                                          return "Selecione um Cliente";
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Icon(
                                      Mdi.currencyUsd,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _currencySymbolDropdownValue,
                                      style: TextStyle(color: Colors.grey[600]),
                                      items: _currencyData!
                                          .map((symbol, name) {
                                            return MapEntry(
                                              symbol,
                                              DropdownMenuItem<String>(
                                                value: symbol,
                                                child: Text("$name"),
                                              ),
                                            );
                                          })
                                          .values
                                          .toList(),
                                      hint: Text(
                                        "Selecione uma Moeda",
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _currencySymbolDropdownValue = value;
                                        });
                                      },
                                      validator: (String? value) {
                                        if (value == null) {
                                          return "Selecione uma Moeda";
                                        }
                                        if (value.isEmpty) {
                                          return "Selecione uma Moeda";
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  icon: Icon(Mdi.cashMultiple),
                                  labelText: 'Valor Obtido *',
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return "Insira um valor";
                                  }
                                  if (value.isEmpty || value == '0,00') {
                                    return "Insira um valor";
                                  }
                                },
                                controller: _tValor,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  RealInputFormatter(centavos: true),
                                ],
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_fVencimento);
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  icon: Icon(Icons.cake),
                                  labelText: 'Data de Vencimento *',
                                ),
                                validator: MultiValidator(
                                  [
                                    RequiredValidator(
                                        errorText: 'Insira uma data válida.'),
                                    MinLengthValidator(10,
                                        errorText: 'Insira uma data válida.'),
                                    PatternValidator(
                                        r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$',
                                        errorText: 'Insira uma data válida.')
                                  ],
                                ),
                                controller: _tVencimento,
                                focusNode: _fVencimento,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_fTaxa);
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  DataInputFormatter(),
                                ],
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  icon: Icon(Mdi.percent),
                                  labelText: 'Taxa de Juros Anual (%) *',
                                ),
                                validator: RequiredValidator(
                                    errorText: 'Insira uma Taxa de Juros.'),
                                controller: _tTaxa,
                                focusNode: _fTaxa,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  _save(context);
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  RealInputFormatter(centavos: true),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  _save(context) async {
    // SQLiteHelper.instance.listLoans().then((loan) => {
    //       print(loan[0].value),
    //     });
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando dados!')),
      );
      print(_clientDropdownValue);
      Client client = (await SQLiteHelper.instance
          .selectClientById(_clientDropdownValue))[0];
      print(client.name);

      Loan loan = Loan(
        _currencySymbolDropdownValue,
        _currencyData![_currencySymbolDropdownValue],
        _tValor.text,
        _tVencimento.text,
        _tTaxa.text,
        client_id: client.id,
      );
      await SQLiteHelper.instance.insertLoan(loan);
      await SQLiteHelper.instance.listLoansJoin().then((loans) => {
            ListLoansPage.loanStreamList.add(loans),
          });
      final snackBar = SnackBar(
        content: Text('Empréstimo Cadastrado!'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  dispose() {
    super.dispose();
    NewLoan.clientStreamList.close();
  }
}
