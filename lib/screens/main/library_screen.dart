import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/books_provider.dart';
import '../../widgets/book_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  var _isInit = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      Provider.of<BooksProvider>(context, listen: false).getBooks();
      _isInit = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<BooksProvider>(context, listen: false).loadMore();
    }
  }

  void _showFilterDialog() {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final categories = booksProvider.categories;
    final years = booksProvider.years;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<BooksProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              title: const Text('Filtros'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filtro por categoría
                    const Text('Categoría:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: provider.selectedCategory,
                      hint: const Text('Todas las categorías'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todas las categorías'),
                        ),
                        ...categories.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        )),
                      ],
                      onChanged: (value) {
                        provider.updateCategory(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Filtro por año
                    const Text('Año de publicación:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: provider.selectedYear,
                      hint: const Text('Todos los años'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todos los años'),
                        ),
                        ...years.map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        )),
                      ],
                      onChanged: (value) {
                        provider.updateYear(value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Limpiar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _getActiveFiltersCount(BooksProvider provider) {
    int count = 0;
    if (provider.searchQuery.isNotEmpty) count++;
    if (provider.selectedCategory != null) count++;
    if (provider.selectedYear != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible 
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar libros...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  Provider.of<BooksProvider>(context, listen: false).updateSearch(value);
                },
              )
            : const Text('Librería'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  Provider.of<BooksProvider>(context, listen: false).updateSearch('');
                }
              });
            },
          ),
          Consumer<BooksProvider>(
    builder: (context, provider, child) {
      final activeFiltersCount = _getActiveFiltersCount(provider);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón para limpiar todos los filtros (solo visible si hay filtros activos)
          if (activeFiltersCount > 0)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Limpiar filtros',
              onPressed: () {
                _searchController.clear();
                provider.clearFilters();
                if (_isSearchVisible) {
                  setState(() {
                    _isSearchVisible = false;
                  });
                }
              },
            ),
          // Botón de filtros con contador
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(),
              ),
              if (activeFiltersCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFiltersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    },
  ),
        ],
      ),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          final books = booksProvider.books;
          final isLoading = booksProvider.isFetching;
          final activeFiltersCount = _getActiveFiltersCount(booksProvider);

          return Column(
            children: [
              // Mostrar filtros activos como chips
              if (activeFiltersCount > 0)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (booksProvider.searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('Buscar: "${booksProvider.searchQuery}"'),
                            onDeleted: () {
                              _searchController.clear();
                              booksProvider.updateSearch('');
                            },
                          ),
                        ),
                      if (booksProvider.selectedCategory != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('Categoría: ${booksProvider.selectedCategory}'),
                            onDeleted: () {
                              booksProvider.updateCategory(null);
                            },
                          ),
                        ),
                      if (booksProvider.selectedYear != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text('Año: ${booksProvider.selectedYear}'),
                            onDeleted: () {
                              booksProvider.updateYear(null);
                            },
                          ),
                        ),
                    ],
                  ),
                ),

              // Contador de resultados
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${books.length} libro${books.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (booksProvider.hasMore)
                      const Text(
                        'Desliza para cargar más',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),

              // Grid de libros
              Expanded(
                child: books.isEmpty && !isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron libros',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Intenta ajustar los filtros',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: books.length + (booksProvider.hasMore ? 1 : 0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (ctx, i) {
                          if (i == books.length) {
                            // Mostrar indicador de carga al final
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return BookItem(book: books[i]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}