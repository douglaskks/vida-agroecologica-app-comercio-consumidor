import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidaagroconsumidor/screens/screens_index.dart';
import 'package:vidaagroconsumidor/screens/signin/components/sign_in_result.dart';
import 'sign_in_repository.dart';

enum SignInStatus {
  done,
  error,
  loading,
  idle,
}

class SignInController with ChangeNotifier {
  final SignInRepository _repository = SignInRepository();
  String? errorMessage;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var status = SignInStatus.idle;

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;

  SignInController() {
    loadSavedEmail();
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  Future<void> loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    if (savedEmail != null) {
      _emailController.text = savedEmail;
      notifyListeners();
    }
  }

  void setErrorMessage(String value) async {
    errorMessage = value;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 3));
    errorMessage = null;
    notifyListeners();
  }

  Future<void> signIn(BuildContext context) async {
    try {
      status = SignInStatus.loading;
      notifyListeners();

      final result = await _repository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      switch (result.type) {
        case SignInResultType.success:
          await saveEmail(_emailController.text);
          status = SignInStatus.done;
          notifyListeners();
          Navigator.pushReplacementNamed(context, Screens.home);
          break;

        case SignInResultType.unauthorized:
          status = SignInStatus.error;
          setErrorMessage('Este aplicativo é exclusivo para consumidores.');
          notifyListeners();
          break;

        case SignInResultType.invalidCredentials:
          status = SignInStatus.error;
          setErrorMessage('E-mail ou senha incorretos.');
          notifyListeners();
          break;

        case SignInResultType.serverError:
          status = SignInStatus.error;
          setErrorMessage(result.message != null ? result.message! : 'Servidor indisponível. Tente novamente mais tarde.');
          notifyListeners();
          break;

        case SignInResultType.networkError:
          status = SignInStatus.error;
          setErrorMessage(result.message != null ? result.message! : 'Verifique sua conexão com a internet.');
          notifyListeners();
          break;
      }
    } catch (e) {
      status = SignInStatus.error;
      setErrorMessage('Ocorreu um erro inesperado. Tente novamente.');
      notifyListeners();
    }
  }
}