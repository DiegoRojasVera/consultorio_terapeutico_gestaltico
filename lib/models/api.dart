import 'dart:convert';
import 'package:http/http.dart' as http;

class Network {
  final String _url = 'http://34.171.207.241/proyecto1/api';
  var token;



  auth(data, apiURL) async {
    var fullUrl = _url + apiURL;
    return await http.post(
        Uri.parse(
          fullUrl,
        ),
        body: jsonEncode(data),
        headers: _setHeaders());
  }

  getData(apiURL) async {
    var fullUrl = _url + apiURL;
    return await http.get(Uri.parse(
      fullUrl,
    ),
      headers: _setHeaders(),
    );
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
