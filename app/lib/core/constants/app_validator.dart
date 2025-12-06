class AppValidator {
  AppValidator._();

  static bool validatePhone(String? value) {
    if (value == null || (value.trim()).isEmpty) {
      return false;
    }

    if (!RegExp(r'^[0-9]{9,10}$').hasMatch(value.trim())) {
      return false;
    }
    return true;
  }

  static bool validateEmail(String? value) {
    if (value == null || (value.trim()).isEmpty) {
      return false;
    }

    if (!RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    ).hasMatch(value.trim())) {
      return false;
    }
    return true;
  }

  static bool validatePassword(String? value) {
    if (value == null || (value.trim()).isEmpty) {
      return false;
    }

    if (value.trim().length < 8) {
      return false;
    }
    return true;
  }
}
