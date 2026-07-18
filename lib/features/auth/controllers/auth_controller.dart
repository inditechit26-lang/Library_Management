import '../services/auth_service.dart';

class AuthController {
  final AuthService service;
  const AuthController({this.service = const AuthService()});
  String? validateEmail(String? value) =>
      service.isValidEmail(value ?? '') ? null : 'Enter a valid email';
  String? validatePassword(String? value) =>
      service.isValidPassword(value ?? '') ? null : 'Minimum 6 characters';
}
