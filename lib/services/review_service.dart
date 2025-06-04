import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Agrega una reseña al libro indicado.
  /// Si el usuario ya dejó una reseña para ese libro, la actualiza.
  Future<void> addReview(String bookId, Review review) async {
    final reviewsRef = _db.collection('books').doc(bookId).collection('reviews');

    // Verificar si ya existe una reseña del mismo usuario
    final existing = await reviewsRef
        .where('userId', isEqualTo: review.userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Actualizar reseña existente
      await existing.docs.first.reference.update(review.toMap());
    } else {
      // Crear nueva reseña
      await reviewsRef.add(review.toMap());
    }
  }

  /// Devuelve un stream con las reseñas del libro.
  Stream<List<Review>> getReviews(String bookId) {
    final reviewsRef = _db
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .orderBy('createdAt', descending: true);

    return reviewsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList());
  }

  /// Devuelve una lista de reseñas hechas por un usuario (útil para "Mis libros").
  Future<List<Review>> getReviewsByUser(String userId) async {
    final query = await _db
        .collectionGroup('reviews')
        .where('userId', isEqualTo: userId)
        .get();

    return query.docs.map((doc) => Review.fromMap(doc.data())).toList();
  }
}
