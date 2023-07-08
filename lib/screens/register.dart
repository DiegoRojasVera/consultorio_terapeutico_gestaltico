import 'package:consultorio_terapeutico_gestaltico/models/api_response.dart';
import 'package:consultorio_terapeutico_gestaltico/models/user.dart';
import 'package:consultorio_terapeutico_gestaltico/screens/home.dart';
import 'package:consultorio_terapeutico_gestaltico/services/user_service.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import 'login.dart';

bool _isObscure = true;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;
  TextEditingController nameController = TextEditingController(),
      emailController = TextEditingController(),
      phoneController = TextEditingController(),
      fechaNController = TextEditingController(),
      passwordController = TextEditingController(),
      idController = TextEditingController(),
      passwordConfirmController = TextEditingController();

  DateTime date = DateTime(2022, 12, 23);

  void _registerUser() async {
    ApiResponse response = await register(
        nameController.text,
        emailController.text,
        fechaNController.text,
        phoneController.text,
        passwordController.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = !loading;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

// Guardar y redirigir a casa
  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Home()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        backgroundColor: Utils.primaryColor,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          children: [
            TextFormField(
              decoration: kInputDecoration('Nombre y Apellido'),
              controller: nameController,
              validator: (val) =>
                  val!.length < 6 ? 'Se requieren al menos 6 caracteres' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty
                    ? 'Dirección de correo electrónico no válida'
                    : null,
                decoration: kInputDecoration('Email')),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: phoneController,
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Por favor, ingrese un número de teléfono';
                }
                final RegExp phoneExp = new RegExp(r'^09\d{8}$');
                if (!phoneExp.hasMatch(val)) {
                  return 'El número de teléfono debe comenzar con 09 y tener 10 dígitos en total';
                }
                return null;
              },
              decoration: kInputDecoration('Teléfono Ej.0981123123'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fecha de nacimiento:   ' '   * opcional',
              style: TextStyle(fontSize: 15),
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '${date.day}/${date.month}/${date.year}'),
              enabled: false,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Utils.secondaryColor),
              child: const Text(
                'Fecha de Nacimiento',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () async {
                DateTime? newDate = await showDatePicker(
                  locale: const Locale("es", "ES"),
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(1940),
                  lastDate: DateTime(2100),
                );
                if (newDate == null) return;
                setState(() => date = newDate);
                fechaNController.text = date.toString();
                print(fechaNController.text);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: _isObscure,
              validator: (val) =>
                  val!.length < 6 ? 'Se requieren al menos 6 caracteres' : null,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black)),
                suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    }),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordConfirmController,
              obscureText: _isObscure,
              validator: (val) => val != passwordController.text
                  ? 'Confirmar contraseña no coincide'
                  : null,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black)),
                suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    }),
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Utils.secondaryColor)))
                : kTextButton(
                    'Registrate',
                    () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          loading = !loading;
                          _registerUser();
                        });
                      }
                    },
                  ),
            const SizedBox(height: 20),
            kLoginRegisterHint(
              '¿Ya tienes una cuenta?  ',
              'Ingresa',
              () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false);
              },
            ),
            const SizedBox(height: 20),

            // Comentario adicional
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 20),
              child: const Text(
                'Recuerda que si completas todos los datos, estarás al tanto de todas las promos.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
