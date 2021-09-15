import 'package:brasil_fields/brasil_fields.dart';
import 'package:emprestimos/Models/client.dart';
import 'package:emprestimos/Pages/new_loan.dart';
import 'package:emprestimos/Utils/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mdi/mdi.dart';

import 'list_clients.dart';

class NewClient extends StatefulWidget {
  Client? client;

  NewClient({this.client});

  @override
  _NewClientState createState() => _NewClientState();
}

class _NewClientState extends State<NewClient> {
  final _formKey = GlobalKey<FormState>();

  final _tName = TextEditingController();
  final _tBirthDate = TextEditingController();
  final _tCPF = TextEditingController();
  final _tRG = TextEditingController();
  final _tTel = TextEditingController();
  final _tEmail = TextEditingController();

  final _fBirthDate = FocusNode();
  final _fCPF = FocusNode();
  final _fRG = FocusNode();
  final _fTel = FocusNode();
  final _fEmail = FocusNode();

  @override
  void initState() {
    if (widget.client != null) {
      _tName.text = widget.client!.name!;
      _tBirthDate.text = widget.client!.birth_date!;
      _tCPF.text = widget.client!.cpf!;
      _tRG.text = widget.client!.RG!;
      _tTel.text = widget.client!.tel!;
      _tEmail.text = widget.client!.email!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Cliente'),
        actions: [
          IconButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              FocusScope.of(context).unfocus();
              save(context);
            },
            icon: Icon(Icons.save),
          ),
          // IconButton(
          //   onPressed: () async {
          //     List<Client> list = await SQLiteHelper.instance.listClients();
          //     list.forEach(
          //       (element) {
          //         print(element.id);
          //       },
          //     );
          //   },
          //   icon: Icon(Icons.read_more),
          // ),
        ],
      ),
      body: SingleChildScrollView(
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
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            labelText: 'Nome Completo *',
                          ),
                          validator: MultiValidator(
                            [
                              RequiredValidator(
                                  errorText: 'Digite o nome completo.'),
                              MinLengthValidator(3,
                                  errorText: 'Mínimo 3 caracteres.'),
                            ],
                          ),
                          controller: _tName,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_fBirthDate);
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.cake),
                            labelText: 'Data de Nascimento *',
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
                          controller: _tBirthDate,
                          focusNode: _fBirthDate,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_fCPF);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            DataInputFormatter(),
                          ],
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Mdi.cardAccountDetails),
                            labelText: 'CPF *',
                          ),
                          validator: (value) {
                            if (!CPFValidator.isValid(value)) {
                              return ("O CPF digitado possui erro");
                            }
                          },
                          controller: _tCPF,
                          focusNode: _fCPF,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_fRG);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CpfInputFormatter(),
                          ],
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Mdi.cardAccountDetails),
                            labelText: 'RG *',
                          ),
                          validator: MultiValidator(
                            [
                              RequiredValidator(errorText: 'Insira o RG.'),
                              MinLengthValidator(6, errorText: 'Insira o RG.'),
                            ],
                          ),
                          controller: _tRG,
                          focusNode: _fRG,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_fTel);
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Mdi.phone),
                            labelText: 'Telefone',
                          ),
                          validator: (value) {
                            if (value!.isNotEmpty) {
                              if (value.length < 14) {
                                //2 ifs pois o nullsafety que não permite incluir na mesma cláusula
                                return ("Insira corretamente o telefone.");
                              }
                            }
                          },
                          controller: _tTel,
                          focusNode: _fTel,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_fEmail);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Mdi.email),
                            labelText: 'Email *',
                          ),
                          controller: _tEmail,
                          focusNode: _fEmail,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            save(context);
                          },
                          validator: MultiValidator(
                            [
                              RequiredValidator(
                                  errorText: 'Insira um email válido.'),
                              EmailValidator(
                                  errorText: 'Insira um email válido.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  save(context) async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando dados!')),
      );
      Client c = Client(
        _tName.text,
        _tBirthDate.text,
        _tCPF.text,
        _tRG.text,
        _tTel.text,
        _tEmail.text,
      );
      if (widget.client != null) {
        c.setId(widget.client!.id!);
        await SQLiteHelper.instance.updateClient(c);
      } else {
        await SQLiteHelper.instance.insertClient(c);
      }

      await SQLiteHelper.instance.listClients().then((clients) => {
            NewLoan.clientStreamList.add(clients),
            ListClientsPage.clientStreamList.add(clients),
          });
      final snackBar = SnackBar(
        content: Text('Cliente Salvo com sucesso!'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
