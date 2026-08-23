import 'package:crypto_trader/features/controller/auth_controller.dart';
import 'package:crypto_trader/features/controller/trade_controller.dart';
import 'package:crypto_trader/features/controller/transaction_controller.dart';
import 'package:crypto_trader/features/controller/watchlist_controller.dart';
import 'package:crypto_trader/features/screen/bitcoin_chart.dart';
import 'package:crypto_trader/features/screen/buy_sell_screen.dart';
import 'package:crypto_trader/features/screen/dashboard_screen.dart';
import 'package:crypto_trader/features/screen/deposit_screen.dart';
import 'package:crypto_trader/features/screen/login_screen.dart';
import 'package:crypto_trader/features/screen/signup_screen.dart';
import 'package:crypto_trader/features/screen/trade_history_screen.dart';
import 'package:crypto_trader/features/screen/transaction_history_screen.dart';
import 'package:crypto_trader/features/screen/wallet_screen.dart';
import 'package:crypto_trader/features/screen/about_screen.dart';
import 'package:crypto_trader/features/screen/watchlist_screen.dart';
import 'package:crypto_trader/features/service/stripe_service.dart';
import 'package:crypto_trader/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  StripeService.init();
  Get.put(AuthController(), permanent: true);
  Get.put(TradeController(), permanent: true);
  Get.put(TransactionController(), permanent: true);
  Get.put(WatchlistController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Crypto Trading App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E676),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/chart', page: () => const BitcoinChart()),
        GetPage(name: '/wallet', page: () => const WalletScreen()),
        GetPage(name: '/deposit', page: () => const DepositScreen()),
        GetPage(name: '/buysell', page: () => const BuySellScreen()),
        GetPage(name: '/trades', page: () => const TradeHistoryScreen()),
        GetPage(
          name: '/transactions',
          page: () => const TransactionHistoryScreen(),
        ),
        GetPage(name: '/watchlist', page: () => const WatchlistScreen()),
        GetPage(name: '/about', page: () => const AboutScreen()),
      ],
    );
  }
}
