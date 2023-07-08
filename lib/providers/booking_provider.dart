import 'dart:convert';

import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  int? _stylistId;
  int? _serviceId;
  DateTime? _datedAt;

  void initData(int stylistId, int serviceId, DateTime datedAt) {
    _stylistId = stylistId;
    _serviceId = serviceId;
    _datedAt = datedAt;
  }

  Validation _name = Validation();

  String get name => _name.value!;

  String? get nameError => _name.error;

  set name(String value) {
    String? errorLength = Validation.hasValidLength(value, min: 5, max: 30);

    if (errorLength != null) {
      _name = Validation(error: errorLength);
    } else {
      _name = Validation(value: value);
    }

    notifyListeners();
  }

  Validation _phone = Validation();

  String? get phone => _phone.value;

  String? get phoneError => _phone.error;

  set phone(String? value) {
    String? errorLength = Validation.hasValidLength(value!, min: 7, max: 20);
    if (errorLength != null) {
      _phone = Validation(error: errorLength);
    } else {
      _phone = Validation(value: value);
    }

    notifyListeners();
  }

  Validation _email = Validation();

  String get email => _email.value!;

  String? get emailError => _email.error;

  set email(String value) {
    String? errorLength = Validation.hasValidLength(value, min: 1, max: 300);

    if (errorLength != null) {
      _email = Validation(error: errorLength);
    } else {
      _email = Validation(value: value);
    }

    notifyListeners();
  }

  Validation _stylistName = Validation();

  String get stylistName => _stylistName.value!;

  String? get stylistNameError => _stylistName.error;

  set stylistName(String value) {
    String? errorLength = Validation.hasValidLength(value, min: 1, max: 300);

    if (errorLength != null) {
      _stylistName = Validation(error: errorLength);
    } else {
      _stylistName = Validation(value: value);
    }

    notifyListeners();
  }

  Validation _inicio = Validation();

  String get inicio => _inicio.value!;

  String? get inicioError => _inicio.error;

  set inicio(String value) {
    String? errorLength = Validation.hasValidLength(value, min: 1, max: 300);

    if (errorLength != null) {
      _inicio = Validation(error: errorLength);
    } else {
      _inicio = Validation(value: value);
    }

    notifyListeners();
  }

  Validation _mensaje = Validation();

  String get mensaje => _mensaje.value!;

  String? get mensajeError => _mensaje.error;

  set mensaje(String value) {
    String? errorLength = Validation.hasValidLength(value, min: 1, max: 300);

    if (errorLength != null) {
      _mensaje = Validation(error: errorLength);
    } else {
      _mensaje = Validation(value: value);
    }

    notifyListeners();
  }

  bool get canSend {
    if (_name.isEmptyOrHasError) return false;
    if (_phone.isEmptyOrHasError) return false;
    if (_email.isEmptyOrHasError) return false;
    //if (stylistName.isEmptyOrHasError) return false;
    if (_inicio.isEmptyOrHasError) return false;
    if (_mensaje.isEmptyOrHasError) return false;
    if (_stylistId == null) return false;
    if (_serviceId == null) return false;
    if (_datedAt == null) return false;
    return true;
  }

  void clean() {
    _stylistId = null;
    _serviceId = null;
    _serviceId = null;
    _datedAt = null;
    _name = Validation();
    _phone = Validation();
    _email = Validation();
    _inicio = Validation();
    _stylistName = Validation();
    _mensaje = Validation();
    notifyListeners();
  }

  Future<bool> save() async {
    final url = Uri.http('34.171.207.241', '/proyecto1/api/services');
    final Map<String, dynamic> data = {
      'client': {
        'name': _name.value,
        'phone': _phone.value,
        'email': _email.value,
        'stylistName': _stylistName.value,
        'inicio': formatTimestamp(_datedAt!),
        'stylist': '$_stylistId',
        'service': '$_serviceId',
        'mensaje': 'no',
      },
      'dated_at': formatTimestamp(_datedAt!),
      'stylist_id': '$_stylistId',
      'service_id': '$_serviceId',
    };
    print("ok concect");
    final response = await http.post(
      url,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );
    print(data);
    print(response.statusCode);
    print(response.body);
    return response.statusCode == 200;
  }
}

class Validation {
  String? value;
  String? error;

  Validation({this.value, this.error});

  bool? get isEmpty {
    if (value == null) return true;
    return value?.isEmpty;
  }

  bool get hasError => error != null;

  bool get isEmptyOrHasError => isEmpty! || hasError;

  static String? hasValidLength(String value,
      {required int min, required int max}) {
    if (min != null && value != null && value.length < min) {
      return "La longitud de texto minima es $min";
    }
    if (max != null && value != null && value.length > max) {
      return "La longitud de texto máxima es $max";
    }
    return null;
  }
}
