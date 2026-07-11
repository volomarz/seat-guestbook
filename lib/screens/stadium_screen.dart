import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/signature.dart';
import '../models/stadium.dart';
import '../services/signatures_store.dart';
import '../theme.dart';
import 'photo_viewer_screen.dart';
import 'sign_seat_screen.dart';

class SeatGroup {
  final String section;
  final String row;
  final String seat;
  final List<SeatSignature> items;
  SeatGroup(this.section, this.row, this.seat, this.items);
}

class StadiumScreen extends StatelessWidget {
  final Stadium stadium;
  const StadiumScreen({super.key, required this.stadium});

  List<SeatGroup> _groupSignatures(List<SeatSignature> sigs) {
    final map = <String, SeatGroup>{};
    for (final sig in sigs) {
      final key = sig.seatKey;
      map.putIfAbsent(key, () => SeatGroup(sig.section, sig.row, sig.seat, []));
      map[key]!.items.add(sig);
    }
    final groups = map.values.toList();
    for (final g in groups) {
      g.items.sort((a, b) => b.date.compareTo(a.date));
    }
    groups.sort((a, b) =>
        ('${a.section}${a.row}${a.seat}').compareTo('${b.section}${b.row}${b.seat}'));
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SignaturesStore>();
    final sigs = store.forStadium(stadium.id);
    final groups = _groupSignatures(sigs);
    final myId = store.userId;

    return Scaffold(
      appBar: AppBar(title: Text(stadium.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SignSeatScreen(stadium: stadium),
                  ),
                ),
                child: const Text('+ Sign a seat',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: groups.isEmpty
                  ? const Center(
                      child: Text('No seats signed here yet. Be the first!',
                          style: TextStyle(color: AppColors.muted)),
                    )
                  : ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, i) {
                        final g = groups[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.line),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Section ${g.section.isEmpty ? '—' : g.section} · '
                                  'Row ${g.row.isEmpty ? '—' : g.row} · '
                                  'Seat ${g.seat.isEmpty ? '—' : g.seat}'
                                  '  (${g.items.length})',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Divider(color: AppColors.line),
                                ...g.items.map((sig) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (sig.photoUrl != null)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: GestureDetector(
                                                onTap: () => Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => PhotoViewerScreen(
                                                      photoUrl: sig.photoUrl!,
                                                      caption: '${sig.name} · ${sig.date}',
                                                    ),
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    sig.photoUrl!,
                                                    width: 52,
                                                    height: 52,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) =>
                                                        const SizedBox(width: 52, height: 52),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text.rich(TextSpan(children: [
                                                  TextSpan(
                                                    text: sig.name,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                  TextSpan(
                                                    text: '  ${sig.date}',
                                                    style: const TextStyle(
                                                        color: AppColors.muted, fontSize: 12),
                                                  ),
                                                ])),
                                                if (sig.note.isNotEmpty)
                                                  Text(sig.note,
                                                      style: const TextStyle(fontSize: 13)),
                                                if (sig.gameSummary != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 3),
                                                    child: Text(
                                                      sig.gameSummary!,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors.dirt,
                                                          fontStyle: FontStyle.italic),
                                                    ),
                                                  ),
                                                if (sig.signerFavoriteTeam != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2),
                                                    child: Text(
                                                      'Fan of ${sig.signerFavoriteTeam}',
                                                      style: const TextStyle(
                                                          fontSize: 11, color: AppColors.muted),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (sig.ownerId == myId)
                                            TextButton(
                                              onPressed: () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Remove signature?'),
                                                    content:
                                                        const Text('This cannot be undone.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx, false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx, true),
                                                        child: const Text('Remove'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed == true) {
                                                  await context
                                                      .read<SignaturesStore>()
                                                      .remove(sig.id);
                                                }
                                              },
                                              child: const Text('remove',
                                                  style: TextStyle(
                                                      color: AppColors.dirt, fontSize: 12)),
                                            )
                                          else
                                            TextButton(
                                              onPressed: () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text('Report this signature?'),
                                                    content: const Text(
                                                        'It will be hidden from everyone while it gets reviewed.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx, false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx, true),
                                                        child: const Text('Report'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirmed == true) {
                                                  await context
                                                      .read<SignaturesStore>()
                                                      .report(sig.id);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Reported. Thanks for flagging it.')));
                                                  }
                                                }
                                              },
                                              child: const Text('report',
                                                  style: TextStyle(
                                                      color: AppColors.muted, fontSize: 12)),
                                            ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}