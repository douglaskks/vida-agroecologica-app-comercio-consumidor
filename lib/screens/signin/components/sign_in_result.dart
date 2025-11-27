enum SignInResultType {
  success,            // Login ok
  unauthorized,       // Não tem permissão (não é consumidor)
  invalidCredentials, // Email/senha errados
  serverError,        // Erro 500, 502, 503
  networkError,       // Sem internet / timeout
}

class SignInResult {
  final SignInResultType type;
  final String? message;

  SignInResult(this.type, {this.message});
}