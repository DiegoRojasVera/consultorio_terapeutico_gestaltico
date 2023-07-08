import 'dart:convert';
import 'dart:io';

import 'package:consultorio_terapeutico_gestaltico/constant.dart';
import 'package:consultorio_terapeutico_gestaltico/models/api_response.dart';
import 'package:http/http.dart' as http;

import '../models/puntuacion.dart';



// Guardar



Future<ApiResponse> calificacion(String calificacion, String stylist, String comentario,
    String nombre, String photo) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(calificacionURL), headers: {
      'Accept': 'application/json'
    }, body: {
      'calificacion': calificacion,
      'stylist': stylist,
      'comentario': comentario,
      'nombre': nombre,
      'photo': photo,
    });

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    switch (response.statusCode) {
      case 200:
        apiResponse.data = Puntuacion.fromJson(jsonDecode(response.body));
        apiResponse.data = jsonDecode(response.body)['message'];

        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      default:
        apiResponse.error = somethingWentWrong;
        print(response);
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}




