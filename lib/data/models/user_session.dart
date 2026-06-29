class UserSession {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String? publicKey;
  final String? privateKey;

  UserSession({
    required this.uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.publicKey,
    this.privateKey,
  });

  /// Convert the UserSession into a JSON Map to save it locally.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }

  /// Create a UserSession object from a JSON Map loaded from local cache.
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      publicKey: json['publicKey'] as String?,
      privateKey: json['privateKey'] as String?,
    );
  }

  /// Create a new session with updated values, preserving existing ones if not provided.
  UserSession copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? publicKey,
    String? privateKey,
  }) {
    return UserSession(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
    );
  }
}
