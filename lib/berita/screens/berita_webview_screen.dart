import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/golfie_colors.dart';

/// Launch a [Uri] in an external browser.
///
/// Top-level so widget tests can override [launchInBrowser] to avoid
/// hitting url_launcher's platform channel.
Future<bool> launchInBrowser(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// In-app browser for a [Berita] article.
///
/// Loads [url] inside an Android/iOS-native [WebView] with progress indicator,
/// a Refresh action, and an "Open externally" fallback when the page fails.
class BeritaWebviewScreen extends StatefulWidget {
  final String title;
  final String url;

  const BeritaWebviewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<BeritaWebviewScreen> createState() => _BeritaWebviewScreenState();
}

class _BeritaWebviewScreenState extends State<BeritaWebviewScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _errorMessage = error.description.isNotEmpty
                  ? error.description
                  : 'Failed to load page';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _reload() async {
    setState(() {
      _errorMessage = null;
      _progress = 0;
    });
    await _controller.reload();
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    final ok = await launchInBrowser(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${widget.url}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _reload,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in browser',
            onPressed: _openExternal,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress > 0 && _progress < 100)
            LinearProgressIndicator(value: _progress / 100.0),
          Expanded(
            child: _errorMessage != null
                ? _WebviewErrorView(
                    message: _errorMessage!,
                    onRetry: _reload,
                    onOpenExternal: _openExternal,
                  )
                : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class _WebviewErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenExternal;

  const _WebviewErrorView({
    required this.message,
    required this.onRetry,
    required this.onOpenExternal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: GolfieColors.stone),
            const SizedBox(height: 12),
            Text(
              'Could not load page',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: GolfieColors.stone),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onOpenExternal,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open externally'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
