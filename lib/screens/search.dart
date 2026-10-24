import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/history.dart';
import 'package:kisekae/screens/products_list.dart';
import 'package:kisekae/services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _productService = SearchService();
  final TextEditingController _searchController = TextEditingController();

  CancelToken? _cancelToken;
  List<SearchHistoryItem> _history = [];
  bool _isLoadingHistory = true;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _cancelToken?.cancel("SearchScreen disposed");
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    _cancelToken?.cancel("Reloading history");
    _cancelToken = CancelToken();

    try {
      final items = await _productService.getSearchHistory(
        cancelToken: _cancelToken,
      );
      items.sort((a, b) {
        final aDate = a.lastSearchedAt ?? a.createdAt;
        final bDate = b.lastSearchedAt ?? b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
      if (!mounted) return;
      setState(() {
        _history = items;
        _isLoadingHistory = false;
      });
    } catch (e) {
      if (!mounted || (e is DioException && CancelToken.isCancel(e))) return;
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    _searchController.text = query;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductListScreen(initialQuery: query)),
    );

    if (mounted) _loadHistory();
  }

  void _showError(Object e, String fallback) {
    final message = e is ApiException ? e.message : fallback;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _removeHistoryItem(SearchHistoryItem item) async {
    final index = _history.indexWhere((h) => h.id == item.id);
    if (index == -1) return;

    setState(() => _history.removeAt(index));

    try {
      await _productService.deleteSearchHistoryItem(item.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _history.insert(index.clamp(0, _history.length), item));
      _showError(e, 'Could not delete search');
    }
  }

  Future<void> _clearAllHistory() async {
    if (_isClearing || _history.isEmpty) return;

    final previous = List<SearchHistoryItem>.from(_history);
    setState(() {
      _history = [];
      _isClearing = true;
    });

    try {
      await _productService.clearSearchHistory();
      if (!mounted) return;
      setState(() => _isClearing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _history = previous;
        _isClearing = false;
      });
      _showError(e, 'Could not clear search history');
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEFE8DF);
    const primaryColor = Color(0xFF8B2E3E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD3C7B8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: _search,
                        decoration: const InputDecoration(
                          hintText: "EXPLORE YOUR STYLE",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.clear,
                          color: Colors.black54,
                          size: 18,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(child: _buildHistorySection(primaryColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(Color primaryColor) {
    if (_isLoadingHistory) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (_history.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: Text(
          "No recent searches",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Search",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _clearAllHistory,
              child: Text(
                "Clear All",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];
              return InkWell(
                onTap: () => _search(item.query),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 20,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.query,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeHistoryItem(item),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
