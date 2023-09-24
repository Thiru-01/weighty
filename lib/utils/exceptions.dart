abstract class RootException implements Exception {
  String getCode();
}

class SignInFailed extends RootException {
  final String _message;

  SignInFailed(this._message);

  @override
  String toString() {
    return "Error: $_message";
  }

  @override
  String getCode() {
    return "E-401";
  }
}
