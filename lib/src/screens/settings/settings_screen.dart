import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeMode = themeProvider.themeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Currency'),
            subtitle: const Text('Indian Rupee (₹)'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(themeMode == ThemeMode.dark ? 'Dark' : 'Light'),
            onTap: () async {
              final selectedTheme = await showDialog<ThemeMode>(
                context: context,
                builder: (dialogContext) {
                  return SimpleDialog(
                    title: const Text('Choose Theme'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.of(dialogContext).pop(ThemeMode.light),
                        child: Row(
                          children: [
                            Icon(
                              themeMode == ThemeMode.light ? Icons.circle : Icons.circle_outlined,
                              color: themeMode == ThemeMode.light ? Theme.of(context).colorScheme.primary : null,
                            ),
                            const SizedBox(width: 12),
                            const Text('Light'),
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.of(dialogContext).pop(ThemeMode.dark),
                        child: Row(
                          children: [
                            Icon(
                              themeMode == ThemeMode.dark ? Icons.circle : Icons.circle_outlined,
                              color: themeMode == ThemeMode.dark ? Theme.of(context).colorScheme.primary : null,
                            ),
                            const SizedBox(width: 12),
                            const Text('Dark'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
              if (selectedTheme != null) {
                themeProvider.setThemeMode(selectedTheme);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Transactions'),
            subtitle: const Text('CSV file'),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reset App'),
            subtitle: const Text('Clear all transactions and start fresh'),
            onTap: () async {
              final provider = Provider.of<TransactionProvider>(context, listen: false);
              final messenger = ScaffoldMessenger.of(context);

              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Reset App'),
                    content: const Text('This will clear all saved transactions and reset your balance to zero. Do you want to continue?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Reset')),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await provider.resetTransactions();
                messenger.showSnackBar(const SnackBar(content: Text('All transactions cleared. Starting fresh.')));
              }
            },
          ),
        ],
      ),
    );
  }
}
