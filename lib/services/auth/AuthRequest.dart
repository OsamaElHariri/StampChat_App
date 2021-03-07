class AuthRequest {
  String token;
  String authProvider;

  AuthRequest({this.authProvider, this.token});

  factory AuthRequest.googleAuth(String t) =>
      AuthRequest(authProvider: 'google', token: t);

  Map<String, Object> toMap() {
    return {'authProvider': authProvider, 'token': token};
  }
}
