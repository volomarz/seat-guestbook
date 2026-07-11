import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/signature.dart';
import '../models/stadium.dart';
import '../services/signatures_store.dart';
import '../theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _mineOnly = false;

  Future<void> _export(BuildContext context, List<SeatSignature> sigs) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/seat-guestbook-backup.json');
    await file.writeAsString(jsonEncode(sigs.map((s) => s.toJson()).toList()));
    final box = context.findRenderObject() as RenderBox;
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Seat guestbook backup',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<SignaturesStore>();
    final allSigs = store.signatures;
    final sigs = _mineOnly
        ? allSigs.where((s) => s.ownerId == store.userId).toList()
        : allSigs;

    final stadiumsVisited = sigs.map((s) => s.stadiumId).toSet().length;
    final seatsSigned = sigs.map((s) => s.seatKey).toSet().length;
    final names =
        sigs.map((s) => s.name.trim().toLowerCase()).where((n) => n.isNotEmpty).toSet().length;

    final perStadium = kStadiums
        .map((s) => MapEntry(s.team, sigs.where((sig) => sig.stadiumId == s.id).length))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = perStadium.isEmpty
        ? 1
        : perStadium.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _ToggleTab(
                    label: 'Everyone',
                    selected: !_mineOnly,
                    onTap: () => setState(() => _mineOnly = false),
                  ),
                ),
                Expanded(
                  child: _ToggleTab(
                    label: 'Mine',
                    selected: _mineOnly,
                    onTap: () => setState(() => _mineOnly = true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              _StatBox(num: '$stadiumsVisited/30', label: 'Stadiums visited'),
              _StatBox(num: '$seatsSigned', label: 'Unique seats signed'),
              _StatBox(num: '${sigs.length}', label: 'Total signatures'),
              _StatBox(num: '$names', label: 'Different signers'),
            ],
          ),
          const SizedBox(height: 20),
          Text(_mineOnly ? 'My signatures per stadium' : 'Signatures per stadium',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: perStadium.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: Text(
                            _mineOnly
                                ? "You haven't signed any seats yet — go sign one!"
                                : 'No signatures yet — go sign a seat!',
                            style: const TextStyle(color: AppColors.muted))),
                  )
                : Column(
                    children: perStadium.map((e) {
                      final fraction = e.value / maxCount;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(e.key,
                                  overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                            ),
                            Expanded(
                              child: Container(
                                height: 10,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEE8D8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: fraction.clamp(0.02, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 24,
                              child: Text('${e.value}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _export(context, sigs),
              child: Text(_mineOnly ? 'Export my data' : 'Export a copy of this data'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String num;
  final String label;
  const _StatBox({required this.num, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.green)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}