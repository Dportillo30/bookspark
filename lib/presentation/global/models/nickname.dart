import 'package:formz/formz.dart';

/// Validation errors for the [Nickname] [FormzInput].
enum NicknameValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template password}
/// Form input for an password input.
/// {@endtemplate}
class Nickname extends FormzInput<String, NicknameValidationError> {
  /// {@macro password}
  const Nickname.pure() : super.pure('');

  /// {@macro password}
  const Nickname.dirty([super.value = '']) : super.dirty();

  static final _passwordRegExp =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  NicknameValidationError? validator(String? value) {
    return _passwordRegExp.hasMatch(value ?? '')
        ? null
        : NicknameValidationError.invalid;
  }
}
