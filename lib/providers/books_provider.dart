import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BooksProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedYear;
  int _page = 1;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _isFetching = false;

  List<Book> get books => _filteredBooks;
  bool get hasMore => _hasMore;
  bool get isFetching => _isFetching;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedYear => _selectedYear;
  
  // Getter para obtener todas las categorías únicas
  List<String> get categories {
    Set<String> categorySet = {};
    for (Book book in _allBooks) {
      if (book.categories != null) {
        categorySet.addAll(book.categories!);
      }
    }
    return categorySet.toList()..sort();
  }

  // Getter para obtener todos los años únicos
  List<String> get years {
    Set<String> yearSet = {};
    for (Book book in _allBooks) {
      if (book.publishedDate != null && book.publishedDate!.isNotEmpty) {
        yearSet.add(book.publishedDate!);
      }
    }
    return yearSet.toList()..sort((a, b) => b.compareTo(a)); // Orden descendente
  }

  Future<void> getBooks({bool refresh = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    notifyListeners();

    if (refresh || _allBooks.isEmpty) {
      // Carga todos los libros solo 1 vez
      _allBooks = await _apiService.getBooks();
      _page = 1;
      _hasMore = true;
    }

    _applyFilters();

    // Calcula cuántos libros mostrar según la página actual
    final totalFiltered = _filteredBooks.length;
    final maxIndex = (_page * _pageSize).clamp(0, totalFiltered);
    _filteredBooks = _filteredBooks.sublist(0, maxIndex);

    // Actualiza si hay más libros para mostrar
    _hasMore = maxIndex < totalFiltered;
    _page++;

    _isFetching = false;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredBooks = _allBooks.where((book) {
      final matchesQuery = book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          (book.authors.contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesCategory = _selectedCategory == null || 
                             (book.categories?.contains(_selectedCategory) ?? false);
      
      final matchesYear = _selectedYear == null || 
                         book.publishedDate == _selectedYear;

      return matchesQuery && matchesCategory && matchesYear;
    }).toList();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    _resetPaginationAndFilter();
  }

  void updateCategory(String? category) {
    _selectedCategory = category;
    _resetPaginationAndFilter();
  }

  void updateYear(String? year) {
    _selectedYear = year;
    _resetPaginationAndFilter();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedYear = null;
    _resetPaginationAndFilter();
  }

  void _resetPaginationAndFilter() {
    _page = 1;
    _applyFilters();
    final totalFiltered = _filteredBooks.length;
    final maxIndex = (_page * _pageSize).clamp(0, totalFiltered);
    _filteredBooks = _filteredBooks.sublist(0, maxIndex);
    _hasMore = maxIndex < totalFiltered;
    notifyListeners();
  }

  // Método para cargar más libros (paginación)
  Future<void> loadMore() async {
    if (!_hasMore || _isFetching) return;
    await getBooks();
  }
}