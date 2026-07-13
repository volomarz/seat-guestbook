import 'package:flutter/material.dart';
import '../models/league.dart';
import '../models/stadium.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../theme.dart';
import 'blocked_users_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  String? _favoriteTeam;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await ProfileService.getName();
    final team = await ProfileService.getFavoriteTeam();
    setState(() {
      _nameCtrl.text = name ?? '';
      _favoriteTeam = team;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await ProfileService.saveProfile(name: _nameCtrl.text.trim(), favoriteTeam: _favoriteTeam);
    await NotificationService.scheduleGameDayReminder(_favoriteTeam);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final teams = [...kStadiums]..sort((a, b) => a.team.compareTo(b.team));
    return Scaffold(
      appBar: AppBar(title: const Text('Your profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Your name', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 4),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Shown on your signatures'),
          ),
          const SizedBox(height: 20),
          const Text('Favorite team', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _favoriteTeam,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                hint: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('None selected'),
                ),
                items: teams
                    .map((s) => DropdownMenuItem(
                          value: s.team,
                          child: Text('${s.team} (${s.league.emoji} ${s.league.label})'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _favoriteTeam = v),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _save,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
              ),
              child: const Text('Blocked people'),
            ),
          ),
        ],
      ),
    );
  }
}