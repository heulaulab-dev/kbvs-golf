import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/berita.dart';
import '../providers/berita_provider.dart';
import '../repositories/berita_repository.dart';
import '../widgets/berita_tile.dart';
import 'berita_webview_screen.dart';

/// The news / berita feed screen.
///
/// Reads the shared [ChangesNotifierBeritaProvider] from the [Provider] tree.
/// If [repository] is supplied explicitly, the screen wraps it in a local
/// [ChangeNotifierProvider] subtree — useful for tests and previews.
class BeritaListScreen extends StatefulWidget {
  final BeritaRepository? repository;

  const BeritaListScreen({super.key, this.repository});

  @override
  State<BeritaListScreen> createState() => _BeritaListScreenState();
}

class _BeritaListScreenState extends State<BeritaListScreen> {
  late ChangesNotifierBeritaProvider _provider;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _ownsProvider = false;

  @override
  void initState() {
    super.initState();
    // Inherit the shared provider from the tree; only construct a local one
    // if the caller passed an explicit repository (tests / previews).
    final shared = context.read<ChangesNotifierBeritaProvider?>();
    if (widget.repository != null) {
      _ownsProvider = true;
      _provider = ChangesNotifierBeritaProvider(
        repository: widget.repository!,
      );
      _provider.loadTrending();
    } else if (shared != null) {
      _provider = shared;
    } else {
      throw StateError(
        'BeritaListScreen requires a BeritaRepository provider ancestor '
        'or an explicit `repository` argument.',
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    if (_ownsProvider) _provider.dispose();
    super.dispose();
  }

  Future<void> _openArticle(Berita item) async {
    if (item.url.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BeritaWebviewScreen(
          title: item.title,
          url: item.url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => _provider.search(q),
              decoration: InputDecoration(
                hintText: 'Search news',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _provider.loadTrending();
                          setState(() {});
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _provider,
              builder: (context, _) {
                if (_provider.isLoading && _provider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_provider.errorText.isNotEmpty && _provider.items.isEmpty) {
                  return _ErrorView(
                    message: _provider.errorText,
                    onRetry: () => _provider.loadTrending(),
                  );
                }
                if (_provider.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _provider.hasSearched
                              ? 'No results for "${_provider.searchQuery}"'
                              : 'No news yet',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _provider.loadTrending,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _provider.items.length,
                    itemBuilder: (context, idx) {
                      final item = _provider.items[idx];
                      return BeritaTile(
                        berita: item,
                        onTap: () => _openArticle(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}