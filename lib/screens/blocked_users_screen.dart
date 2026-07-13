import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/blocked_users_service.dart';
import '../services/signatures_store.dart';
import '../theme.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<BlockedUser> _blocked = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final blocked = await BlockedUsersService.getBlocked();
    if (mounted) {
      setState(() {
        _blocked = blocked;
        _loading = false;
      });
    }
  }

  Future<void> _unblock(BlockedUser user) async {
    await context.read<SignaturesStore>().unblock(user.ownerId);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unblocked ${user.name}.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked people')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _blocked.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "You haven't blocked anyone. When you do, they'll show up here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blocked.length,
                  itemBuilder: (context, i) {
                    final user = _blocked[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.line),
                      ),
                      child: ListTile(
                        title: Text(user.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: TextButton(
                          onPressed: () => _unblock(user),
                          child: const Text('Unblock'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
