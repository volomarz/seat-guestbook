import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/profile_service.dart';
import 'services/signatures_store.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  runApp(const SeatGuestbookApp());
}

class SeatGuestbookApp extends StatefulWidget {
  const SeatGuestbookApp({super.key});
  @override
  State<SeatGuestbookApp> createState() => _SeatGuestbookAppState();
}

class _SeatGuestbookAppState extends State<SeatGuestbookApp> {
  final SignaturesStore _store = SignaturesStore();

  @override
  void initState() {
    super.initState();
    _store.load();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    await NotificationService.requestPermission();
    final favoriteTeam = await ProfileService.getFavoriteTeam();
    await NotificationService.scheduleGameDayReminder(favoriteTeam);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignaturesStore>.value(
      value: _store,
      child: MaterialApp(
        title: 'Seat Guestbook',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}