// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:vidaagroconsumidor/shared/constants/app_text_constants.dart';
import 'package:vidaagroconsumidor/shared/core/user_storage.dart';

class SignInRepository {
  final userStorage = UserStorage();
  String userId = "0";
  String userToken = "0";

  final _dio = Dio();

  Future<bool> checkEmailExists(String email) async {
    try {
      // Token fixo para API - importante usar o mesmo token em todas as requisições
      String token = "401|SdE56cPwKTJSSAA5Rn4pc4LprbxYhrSiT28QPOLtdeaf5e31";
      print('Token usado para verificar existência do email: $token');

      final response = await _dio.get(
        '$kBaseURL/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        List users = response.data['users'];
        print('Usuários obtidos: ${users.length}');
        
        // Log de todos os emails para debugging
        print('Lista de emails:');
        for (var user in users) {
          print('  ${user['email']}');
        }
        
        for (var user in users) {
          print('Verificando email do usuário: ${user['email']}');
          if (user['email'].toString().toLowerCase() == email.toLowerCase()) {
            print('Email encontrado: ${user['email']}');
            return true;
          }
        }
        print('Email não encontrado: $email');
        return false;
      } else {
        print('Falha ao buscar usuários, código de status: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Erro ao verificar existência do email: $error');
      // Se ocorrer um erro, vamos retornar true para permitir que o processo continue
      // Isso evita bloqueios por problemas de rede/API
      print('Retornando true para permitir que o processo continue');
      return true;
    }
  }

  Future<void> sendResetPasswordEmail(String email) async {
    try {
      // Usar o mesmo token fixo que é usado em checkEmailExists
      String token = "401|SdE56cPwKTJSSAA5Rn4pc4LprbxYhrSiT28QPOLtdeaf5e31";
      print('Token usado para enviar email de redefinição: $token');

      print('Enviando solicitação de redefinição para: $email');
      
      final response = await _dio.post(
        '$kBaseURL/forgot-password',
        data: {'email': email},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Resposta da API (reset): ${response.statusCode}');
      print('Dados da resposta: ${response.data}');
      
      // Aceitar tanto 200 quanto 201 como códigos de sucesso
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Falha ao enviar email de redefinição de senha');
      }
    } catch (error) {
      print('Erro ao enviar email de redefinição de senha: $error');
      // Verificar se é um erro de DioError para obter mais detalhes
      if (error is DioError) {
        print('Status code: ${error.response?.statusCode}');
        print('Resposta: ${error.response?.data}');
      }
      throw Exception('Falha ao enviar email de redefinição de senha');
    }
  }

  Future<int> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$kBaseURL/sanctum/token',
        data: {'email': email, 'password': password, 'device_name': "PC"},
      );
      if (response.statusCode == 200) {
        if (await userStorage.userHasCredentials()) {
          await userStorage.clearUserCredentials();
        }
        userId = response.data['user']['id'].toString();
        userToken = response.data['token'].toString();
        await userStorage.saveUserCredentials(
          id: userId,
          nome: response.data['user']['name'].toString(),
          token: userToken,
          email: response.data['user']['email'].toString(),
        );
        try {
          Response response = await _dio.get('$kBaseURL/users/$userId',
              options:
                  Options(headers: {"Authorization": "Bearer $userToken"}));
          if (response.statusCode == 200) {
            if (response.data["user"].isEmpty) {
              return 2;
            } else {
              return 1;
            }
          }
        } catch (e) {
          return 0;
        }
        return 1;
      }
    } catch (e) {
      print('Erro ao fazer login: $e');
      return 0;
    }
    return 0;
  }
}