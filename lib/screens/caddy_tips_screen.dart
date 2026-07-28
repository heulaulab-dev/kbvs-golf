import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';

class CaddyTipsScreen extends StatelessWidget {
  const CaddyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, child) {
        // If caddy tips disabled, show empty state message
        if (!app.caddyTipsEnabled) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 64, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'Caddy Tips Disabled',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toggle on in the header to enable caddy tips',
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
                _buildInputCard(context),
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

  Widget _buildInputCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Yardage',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
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
    // Use AnimatedContainer for fee transition on change
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.shade300, width: 1),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (app.currentFee != null)
                    Text(
                      '\$${app.currentFee!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    // Placeholder when no fee
                    Text(
                      '--.00',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey.shade400,
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
                    color: Colors.grey.shade200,
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
                          color: Colors.green.shade400,
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
                const Center(child: Text('No fee calculated — enter a yardage')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsArea(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pro Tip',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'On par-3 holes under 150 yards, recommend a wedge with extra grip tape for better control.',
              style: TextStyle(
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: const Text('Club Selection'),
              backgroundColor: Colors.purple.shade100,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
