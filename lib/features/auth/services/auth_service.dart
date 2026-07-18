class AuthService {
  const AuthService();
  bool isValidEmail(String value) => value.contains('@');
  bool isValidPassword(String value) => value.length >= 6;
}
