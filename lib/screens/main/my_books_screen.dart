import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final booksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_books')
        .orderBy('savedAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Libros')),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aún no has guardado libros.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Sin título';
              final authors = (data['authors'] as List<dynamic>?)?.join(', ') ?? 'Desconocido';
              final thumbnail = (data['imageLinks']?['thumbnail']) ?? '';

              return Dismissible(
                key: Key(doc.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  // Confirmación antes de eliminar
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar libro'),
                      content: const Text('¿Estás seguro de que deseas eliminar este libro de tu biblioteca?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await doc.reference.delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Libro "$title" eliminado')),
                  );
                },
                child: ListTile(
                  leading: thumbnail.isNotEmpty
                      ? Image.network(thumbnail, width: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book),
                  title: Text(title),
                  subtitle: Text(authors),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
