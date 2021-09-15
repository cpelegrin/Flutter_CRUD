import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionStatus {
  static testarConexao() async {
    var resultadoConexao = await (Connectivity().checkConnectivity());
    if (resultadoConexao == ConnectivityResult.none)
      return -1;
    else if (resultadoConexao == ConnectivityResult.wifi)
      return 2;
    else if (resultadoConexao == ConnectivityResult.mobile)
      return 2;
    else
      return -1;
  }
}
