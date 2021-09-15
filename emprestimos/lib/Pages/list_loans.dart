import 'dart:async';
import 'dart:math';
import 'package:emprestimos/Pages/new_loan.dart';
import 'package:emprestimos/Utils/connection_status.dart';
import 'package:emprestimos/Widgets/drawer_navigation_widget.dart';
import 'package:intl/intl.dart';
import 'dart:convert' as convert;

import 'package:emprestimos/Models/loan.dart';
import 'package:emprestimos/Utils/sqlite_helper.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:http/http.dart' as http;

class ListLoansPage extends StatefulWidget {
  static StreamController<List<Loan>> loanStreamList =
      StreamController<List<Loan>>();

  @override
  _ListLoansPageState createState() => _ListLoansPageState();
}

class _ListLoansPageState extends State<ListLoansPage> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    await buscaCotacao();
    await SQLiteHelper.instance.listLoansJoin().then((loans) => {
          ListLoansPage.loanStreamList.add(loans),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empréstimos'),
        actions: [
          IconButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return NewLoan();
                  },
                ),
              );
            },
            icon: Icon(Mdi.cashPlus),
          ),
        ],
      ),
      drawer: SafeArea(
        child: DrawerNavigationWidget(),
      ),
      body: StreamBuilder(
        stream: ListLoansPage.loanStreamList.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Loan>? loans = snapshot.data as List<Loan>?;
            if (loans != null) {
              if (loans.isNotEmpty) {
                return ListView.builder(
                  itemCount: loans.length,
                  itemBuilder: (context, index) {
                    int parcelas = calculaParcelas(
                        loans[index].date_of_loan, loans[index].maturity);
                    double montante = calculaMontante(
                        loans[index].value, parcelas, loans[index].tax);
                    double valorParcelaDouble = (montante / parcelas);
                    if (parcelas == 0) {
                      valorParcelaDouble = double.parse(
                          loans[index].value!.replaceAll(",", "."));
                    }
                    String valorParcela =
                        valorParcelaDouble.toString().replaceAll(".", ",");
                    if (valorParcela
                            .substring(valorParcela.indexOf(","))
                            .length >
                        3) {
                      valorParcela = valorParcela.substring(
                          0, valorParcela.indexOf(",") + 3);
                    }
                    String montanteString =
                        montante.toString().replaceAll(".", ",");
                    if (montanteString
                            .substring(montanteString.indexOf(","))
                            .length >
                        3) {
                      montanteString = montanteString.substring(
                          0, montanteString.indexOf(",") + 3);
                    }
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Mdi.accountCash),
                            title: Text('Empréstimo ${loans[index].loan_id}'),
                            subtitle: Text(
                              'Cliente: ${loans[index].clientName}',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 72, top: 16),
                            child: RichText(
                              text: TextSpan(
                                text: 'Data do Empréstimo: ',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '${loans[index].date_of_loan}\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  TextSpan(text: 'Valor: '),
                                  TextSpan(
                                    text:
                                        '${loans[index].currency_symbol} ${loans[index].value}\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Moeda: '),
                                  TextSpan(
                                    text: '${loans[index].currency_name}\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Taxa: '),
                                  TextSpan(
                                    text: '${loans[index].tax}% A.A\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Vencimento: '),
                                  TextSpan(
                                    text: '${loans[index].maturity}\n\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Número de Parcelas: '),
                                  TextSpan(
                                    text: '$parcelas\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Valor de cada parcela: '),
                                  TextSpan(
                                    text:
                                        '${loans[index].currency_symbol} $valorParcela\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Montante: '),
                                  TextSpan(
                                    text:
                                        '${loans[index].currency_symbol} $montanteString\n\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(
                                      text: 'Valor de cada parcela em Reais: '),
                                  TextSpan(
                                    text:
                                        'R\$ ${converterValores(loans[index].currency_symbol, valorParcelaDouble)}\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(text: 'Montante em Reais: '),
                                  TextSpan(
                                    text:
                                        'R\$ ${converterValores(loans[index].currency_symbol, montante)}\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\n*Utilizando a cotação de hoje:\n'
                                        '${loans[index].currency_symbol} 1,00 = R\$ ${(_cotacoesHoje![loans[index].currency_symbol])!.replaceAll('.', ',')}\n',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
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
                                  onPrimary: Theme.of(context).accentColor,
                                  side: BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1),
                                ),
                                onPressed: () async {
                                  await SQLiteHelper.instance
                                      .deleteLoan(loans[index].loan_id);
                                  await SQLiteHelper.instance
                                      .listLoansJoin()
                                      .then((loans) => {
                                            ListLoansPage.loanStreamList
                                                .add(loans),
                                          });
                                  await SQLiteHelper.instance
                                      .listLoansJoin()
                                      .then((loans) => {
                                            ListLoansPage.loanStreamList
                                                .add(loans),
                                          });
                                },
                                child: const Text('Deletar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.white,
                                  primary: Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return NewLoan(
                                          loan: loans[index],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text('Atualizar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            }
            return Center(child: Text("Nenhum Empréstimo Cadastrado"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  calculaParcelas(String? date_of_loan, String? maturity) {
    var init = DateFormat('dd/MM/yyyy').parse(date_of_loan!);
    var end = DateFormat('dd/MM/yyyy').parse(maturity!);
    var result = end.difference(init);
    return (result.inDays ~/ 30); //resultado aproximado
  }

  calculaMontante(String? value, int parcelas, String? tax) {
    double capital = double.parse(value!.replaceAll(",", "."));
    double juros = double.parse(tax!.replaceAll(",", ".")) / 100;
    juros /= 12;
    double montante = capital * pow((1 + juros), parcelas);
    return montante;
  }

  List<String>? _currencyData = [];
  Map<String, String>? _cotacoesHoje = {};

  buscaCotacao() async {
    if (await ConnectionStatus.testarConexao() != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problemas na conexão')),
      );
    } else {
      var urlCurrency = Uri.parse(
          "https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/Moedas?\$top=100&\$format=json");
      var response = await http.get(urlCurrency);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        jsonResponse['value'].forEach((currency) {
          _currencyData!.add(currency['simbolo']);
        });
      } else {
        print(response.statusCode);
        return;
      }

      var date = DateFormat('MM-dd-yyyy').format(DateTime.now());
      _currencyData!.forEach(
        (element) async {
          var url = Uri.parse(
              "https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoMoedaPeriodoFechamento(codigoMoeda=@codigoMoeda,dataInicialCotacao=@dataInicialCotacao,dataFinalCotacao=@dataFinalCotacao)?%40codigoMoeda='$element'&%40dataInicialCotacao='$date'&%40dataFinalCotacao='$date'&\$format=json");
          var response = await http.get(url);
          if (response.statusCode == 200) {
            var jsonResponse = convert.jsonDecode(response.body);
            jsonResponse['value'].forEach((currency) {
              _cotacoesHoje!
                  .addAll({element: currency['cotacaoCompra'].toString()});
            });
          } else {
            print(response.statusCode);
          }
        },
      );
    }
  }

  converterValores(simbolo, valor) {
    double cotacao = double.parse(_cotacoesHoje![simbolo]!);
    double convertido = valor * cotacao;
    String convString = convertido.toString().replaceAll(".", ",");
    convString = convString.substring(0, convString.indexOf(",") + 3);

    return convString;
  }

  @override
  dispose() {
    super.dispose();
    ListLoansPage.loanStreamList.close();
    ListLoansPage.loanStreamList = StreamController<List<Loan>>();
  }
}
