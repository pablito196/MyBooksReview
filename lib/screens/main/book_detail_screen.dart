import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/book.dart';
import '../../models/review.dart';
import '../../services/review_service.dart'; // servicio que define addReview y getReviews

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _commentController = TextEditingController();
  double _rating = 3.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final review = Review(
      id: '',
      userId: user.uid,
      userName: user.displayName ?? 'Anónimo',
      rating: _rating,
      comment: _commentController.text,
      createdAt: DateTime.now(),
    );

    await ReviewService().addReview(widget.book.id, review);
    _commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reseña enviada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Detalle del libro
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        book.imageLinks?.thumbnail ?? '',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Autor(es): ${book.authors.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      book.description != null && book.description!.isNotEmpty
                          ? book.description!.length > 200
                              ? '${book.description!.substring(0, 200)}...'
                              : book.description!
                          : 'No hay descripción disponible.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Reseñas existentes
                    Text('Reseñas:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Review>>(
                      stream: ReviewService().getReviews(book.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final reviews = snapshot.data ?? [];

                        if (reviews.isEmpty) {
                          return const Text('No hay reseñas aún.');
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final r = reviews[index];
                            return ListTile(
                              title: Text(r.userName),
                              subtitle: Text(r.comment),
                              trailing: Text('${r.rating} ⭐'),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Formulario de reseña
                    Text('Deja tu reseña:', style: Theme.of(context).textTheme.titleMedium),
                    Slider(
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      value: _rating,
                      onChanged: (value) {
                        setState(() => _rating = value);
                      },
                    ),
                    TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(labelText: 'Comentario'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _submitReview,
                      child: const Text('Enviar Reseña'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
