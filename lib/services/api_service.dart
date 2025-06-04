import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../models/book.dart';

const String baseUrl = 'https://reactnd-books-api.udacity.com';

class ApiService {
  Future<List<Book>> getBooks({int page = 1, int limit = 10}) async {
    final token = await TokenService.getOrCreateToken();

    final response = await http.get(
    Uri.parse('$baseUrl/books?page=$page&limit=$limit'),
    headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
    },
  );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final booksJson = data['books'] as List<dynamic>; // <- aquí el cast explícito
      final books = booksJson.map((json) => Book.fromJson(json)).toList();
      return books;
    } else {
      throw Exception('Error al obtener libros');
    }
  }
}