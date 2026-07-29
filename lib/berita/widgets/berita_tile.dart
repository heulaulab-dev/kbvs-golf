import 'package:flutter/material.dart';

import '../models/berita.dart';

/// A list tile card for a [Berita] entry.
///
/// Designed to be displayed in a vertical list. Pure presentation —
/// tapping is handled by the parent (typically opens the URL via [url_launcher]).
class BeritaTile extends StatelessWidget {
  final Berita berita;
  final VoidCallback? onTap;

  const BeritaTile({
    super.key,
    required this.berita,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (berita.imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  berita.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    height: 120,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 120,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    berita.snippet,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade700),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.public, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          berita.source,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        berita.relativeDate,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}