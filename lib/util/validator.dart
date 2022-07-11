/// Matches most names, including those that contains spaces.
RegExp validNameRegex =
    RegExp(r"^[\w'\-][^,.0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{1,}$");

/// Matches valid email addresses.
RegExp validEmailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

///  Matches passwords with at least:
///    - 8 characters
///    - One letter
///    - One number
///    - One special character
RegExp validPasswordRegex =
    RegExp(r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$");

/// Returns true if [name] is a valid name.
bool isValidName(String name) {
  return validNameRegex.hasMatch(name);
}

/// Returns true if [email] is a valid email address.
bool isValidEmail(String email) {
  return validEmailRegex.hasMatch(email);
}

/// Returns true if [password] satisfies password requirements.
bool isValidPassword(String password) {
  return validPasswordRegex.hasMatch(password);
}
