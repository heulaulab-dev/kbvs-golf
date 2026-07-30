import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../core/theme/golfie_colors.dart';
import '../core/theme/golfie_typography.dart';
import '../widgets/golfie/golfie_index.dart';

class CaddyTipsScreen extends StatelessWidget {
  const CaddyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<AppState>(
      builder: (context, app, child) {
        // If caddy tips disabled, show empty state message
        if (!app.caddyTipsEnabled) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 64, color: GolfieColors.stone),
                  const SizedBox(height: 16),
                  Text(
                    'Caddy Tips Disabled',
                    style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: GolfieColors.ink,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toggle on in the header to enable caddy tips',
                    style: textTheme.bodyMedium?.copyWith(
                      color: GolfieColors.stone,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Caddy tips enabled — show calculator UI
        return Scaffold(
          appBar: AppBar(
            title: const Text('Caddy Tips'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () {},
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Yardage input card
                _buildInputCard(context, app),
                const SizedBox(height: 24),

                // Fee result card with animated update
                _buildResultCard(context, app),

                const SizedBox(height: 24),

                // Shot suggestion area (placeholder)
                _buildSuggestionsArea(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputCard(BuildContext context, AppState app) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: GolfieColors.ash, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Yardage',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: GolfieColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Yards',
                      hintStyle: TextStyle(color: GolfieColors.stone),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: GolfieColors.periwinkle, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    textAlign: TextAlign.right,
                    onChanged: (value) {
                      final yardage = int.tryParse(value) ?? 0;
                      context.read<AppState>().setYardage(yardage);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Action button with press feedback
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: GolfieColors.ink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: GolfieColors.white),
                    onPressed: () {},
                    splashRadius: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, AppState app) {
    final textTheme = Theme.of(context).textTheme;
    // Use AnimatedContainer for fee transition on change
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: GolfieColors.mint, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Caddy Fee',
                    style: textTheme.bodyMedium?.copyWith(
                      color: GolfieColors.stone,
                    ),
                  ),
                  if (app.currentFee != null)
                    Text(
                      '\$${app.currentFee!.toStringAsFixed(2)}',
                      style: textTheme.headlineSmall?.copyWith(
                        color: GolfieColors.mint,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    // Placeholder when no fee
                    Text(
                      '--.00',
                      style: textTheme.headlineSmall?.copyWith(
                        color: GolfieColors.stone,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar showing fee breakdown (hidden if no fee)
              if (app.currentFee != null)
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: GolfieColors.ash,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: ((app.currentFee! / 300.0) * (MediaQuery.of(context).size.width - 128))
                            .clamp(0.0, (MediaQuery.of(context).size.width - 128)),
                        height: 6,
                        decoration: BoxDecoration(
                          color: GolfieColors.mint,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // Show breakdown or empty state
              if (app.currentYardage != null && app.currentYardage! > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.ltr,
                  children: [
                    SmallFeeItem(label: 'Base fee', value: '\$2.00'),
                    SmallFeeItem(
                      label: 'Distance (${app.currentYardage} yds)',
                      value: '\$${(app.currentYardage! * 0.5).toStringAsFixed(2)}',
                    ),
                    const Spacer(),
                  ],
                )
              else if (app.currentFee == null && app.currentYardage == null)
                Center(child: Text('No fee calculated — enter a yardage', style: textTheme.bodyMedium?.copyWith(color: GolfieColors.stone))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsArea(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: GolfieColors.periwinkle, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pro Tip',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: GolfieColors.periwinkle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'On par-3 holes under 150 yards, recommend a wedge with extra grip tape for better control.',
              style: TextStyle(
                color: GolfieColors.ink,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: const Text('Club Selection'),
              backgroundColor: GolfieColors.periwinkle.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}

// Small fee item component with subtle entry animation
class SmallFeeItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const SmallFeeItem({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: GolfieColors.stone,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color ?? GolfieColors.ink,
          ),
        ),
      ],
    );
  }
}
