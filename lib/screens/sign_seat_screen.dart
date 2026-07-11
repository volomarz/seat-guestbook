import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/signature.dart';
import '../models/stadium.dart';
import '../services/mlb_stats_service.dart';
import '../services/profile_service.dart';
import '../services/signatures_store.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class SignSeatScreen extends StatefulWidget {
  final Stadium stadium;
  const SignSeatScreen({super.key, required this.stadium});

  @override
  State<SignSeatScreen> createState() => _SignSeatScreenState();
}

class _SignSeatScreenState extends State<SignSeatScreen> {
  final _sectionCtrl = TextEditingController();
  final _rowCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String? _photoPath; // local temp path from picker, before upload
  String? _favoriteTeam;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await ProfileService.getName();
    final team = await ProfileService.getFavoriteTeam();
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _nameCtrl.text = name;
        _favoriteTeam = team;
      });
    }
  }

  @override
  void dispose() {
    _sectionCtrl.dispose();
    _rowCtrl.dispose();
    _seatCtrl.dispose();
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await picker.pickImage(source: source, imageQuality: 70, maxWidth: 1080);
    if (picked != null) {
      setState(() => _photoPath = picked.path);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _sectionCtrl.text.trim().isEmpty ||
        _seatCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in at least section, seat, and your name.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final store = context.read<SignaturesStore>();
      final ownerId = store.userId ?? '';
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final dateStr = DateFormat('yyyy-MM-dd').format(_date);

      String? photoUrl;
      if (_photoPath != null) {
        photoUrl = await StorageService.uploadPhoto(_photoPath!, id);
      }

      final gameSummary =
          await MlbStatsService.fetchGameSummary(widget.stadium.id, dateStr);

      final sig = SeatSignature(
        id: id,
        stadiumId: widget.stadium.id,
        section: _sectionCtrl.text.trim(),
        row: _rowCtrl.text.trim(),
        seat: _seatCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        date: dateStr,
        note: _noteCtrl.text.trim(),
        photoUrl: photoUrl,
        ownerId: ownerId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        gameSummary: gameSummary,
        signerFavoriteTeam: _favoriteTeam,
      );
      await store.add(sig);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign a seat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _fieldLabel('Section'),
          TextField(controller: _sectionCtrl, decoration: const InputDecoration(hintText: 'e.g. 128')),
          const SizedBox(height: 12),
          _fieldLabel('Row'),
          TextField(controller: _rowCtrl, decoration: const InputDecoration(hintText: 'e.g. 12')),
          const SizedBox(height: 12),
          _fieldLabel('Seat'),
          TextField(controller: _seatCtrl, decoration: const InputDecoration(hintText: 'e.g. 4')),
          const SizedBox(height: 12),
          _fieldLabel('Your name'),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: "Who's signing?")),
          const SizedBox(height: 12),
          _fieldLabel('Date'),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(),
              child: Text(DateFormat('yyyy-MM-dd').format(_date)),
            ),
          ),
          const SizedBox(height: 12),
          _fieldLabel('Note (optional)'),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Any memory from the seat...'),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: _pickPhoto,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: AppColors.green),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(_photoPath == null ? '+ Add photo / selfie' : 'Change photo'),
          ),
          if (_photoPath != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(_photoPath!), width: 100, height: 100, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save signature', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
      );
}