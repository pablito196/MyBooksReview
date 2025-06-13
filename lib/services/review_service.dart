import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Future<void> addReview(String bookId, Review review) async {
    final reviewsRef = _db.collection('books').doc(bookId).collection('reviews');

    final existing = await reviewsRef
        .where('userId', isEqualTo: review.userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update(review.toMap());
    } else {
      await reviewsRef.add(review.toMap());
    }
  }

  
  Stream<List<Review>> getReviews(String bookId) {
    final reviewsRef = _db
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .orderBy('createdAt', descending: true);

    return reviewsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList());
  }

  
  Future<List<Review>> getReviewsByUser(String userId) async {
    final query = await _db
        .collectionGroup('reviews')
        .where('userId', isEqualTo: userId)
        .get();

    return query.docs.map((doc) => Review.fromMap(doc.data())).toList();
  }
}
