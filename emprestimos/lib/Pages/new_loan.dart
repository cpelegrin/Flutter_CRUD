import 'dart:async';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:emprestimos/Models/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mdi/mdi.dart';

import '../sqlite_helper.dart';

class NewLoan extends StatefulWidget {
  @override
  State<NewLoan> createState() => _NewLoanState();
}

class _NewLoanState extends State<NewLoan> {
  ///cadastro de Emprestimos (simples)
  // data do empréstimo * pega data atual para salvar no banco
  // moeda (de preferência utilizar a lista do Banco Central) dropdown button
  // valor obtido
  // data de vencimento
  // taxa de conversão para reais em data atual (de preferência obtida no Banco Central) (somente UI)

  final _formKey = GlobalKey<FormState>();

  final _tValor = TextEditingController();
  final _tVencimento = TextEditingController();
  final _tTaxa = TextEditingController();

  final _fVencimento = FocusNode();
  final _fTaxa = FocusNode();

  String? _chosenValue;

  StreamController<List<Client>> clientStreamList =
      StreamController<List<Client>>();

  @override
  void initState() {
    SQLiteHelper.instance.listClients().then((clients) => {
          clientStreamList.add(clients),
        });
    // inicializar dropdownButtons com dados da api
    // talvez incluir uma splash para fazer download dos dados
    super.initState();
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
          stream: clientStreamList.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
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
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Icon(
                                        Icons.person_add,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _chosenValue,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                        items:
                                            snapshot.data!.map((Client client) {
                                          return DropdownMenuItem<String>(
                                            value: client.id.toString(),
                                            child: Text("${client.name}"),
                                          );
                                        }).toList(),
                                        hint: Text(
                                          "Selecione um cliente",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            _chosenValue = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.money),
                                    labelText: 'Valor Obtido *',
                                  ),
                                  validator: MultiValidator(
                                    [
                                      RequiredValidator(
                                          errorText: 'Digite o nome completo.'),
                                      PatternValidator(
                                          r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$',
                                          errorText: 'Insira uma data válida.')
                                    ],
                                  ),
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
                                    icon: Icon(Mdi.cardAccountDetails),
                                    labelText: 'Taxa de Juros (%) *',
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
          }),
    );
  }

  _save(context) async {
    //   if (_formKey.currentState!.validate()) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Salvando dados!')),
    //     );
    //     Client c = Client(
    //       _tName.text,
    //       _tBirthDate.text,
    //       _tCPF.text,
    //       _tRG.text,
    //       _tTel.text,
    //       _tEmail.text,
    //     );
    //     await SQLiteHelper.instance.insertClient(c);
    //
    //     final snackBar = SnackBar(
    //       content: Text('Cliente Salvo com sucesso!'),
    //       action: SnackBarAction(
    //         label: 'Ok',
    //         onPressed: () {},
    //       ),
    //     );
    //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   }

    @override
    dispose() {
      super.dispose();
      clientStreamList.close();
    }
  }
}
