import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/providers/achievement_provider.dart';
import 'src/providers/theme_provider.dart';
import 'src/providers/transaction_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProxyProvider<TransactionProvider, AchievementProvider>(
          create: (_) => AchievementProvider(),
          update: (_, transactionProvider, achievementProvider) {
            achievementProvider!.update(transactionProvider.transactions);
            return achievementProvider;
          },
        ),
      ],
      child: const PiggyBankApp(),
    ),
  );
}
