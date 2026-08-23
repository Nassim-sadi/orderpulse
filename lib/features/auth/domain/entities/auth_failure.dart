enum AuthFailureKind {
  invalidCredentials,
  emailInUse,
  weakPassword,
  invalidEmail,
  network,
  tooManyRequests,
  googleCancelled,
  googleNoAccount,
  googleUnavailable,
  unknown,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind, [this.detail]);

  final AuthFailureKind kind;
  final String? detail;

  @override
  String toString() => 'AuthFailure($kind${detail == null ? '' : ': $detail'})';
}
