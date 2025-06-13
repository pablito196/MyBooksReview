import 'package:firebase_auth/firebase_auth.dart';

Future<void> seedUsersWithAuth() async {
  final users = [
    {"email": "user1@sistema.com", "password": "password123"},
    {"email": "user2@sistema.com", "password": "password456"},
  ];

  for (var user in users) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: user['email']!,
        password: user['password']!,
      );
      print("Usuario creado: ${user['email']}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("El usuario ya existe: ${user['email']}");
      } else {
        print("Error al crear usuario ${user['email']}: ${e.message}");
      }
    }
  }
}
