import 'package:intl/intl.dart';

class Loan {
  int? loan_id;
  String? date_of_loan;
  String? currency_symbol;
  String? currency_name;
  String? value;
  String? maturity;
  String? tax;
  int? client_id;
  String? clientName;

  Loan(this.currency_symbol, this.currency_name, this.value, this.maturity,
      this.tax,
      {loan_id, client_id, date_of_loan, clientName}) {
    this.loan_id = loan_id;
    this.client_id = client_id;
    this.clientName = clientName;
    this.date_of_loan =
        date_of_loan ?? DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'loan_id': loan_id,
      'date_of_loan': date_of_loan,
      'currency_symbol': currency_symbol,
      'currency_name': currency_name,
      'value': value,
      'maturity': maturity,
      'tax': tax,
      'client_id': client_id,
    };
  }
}
