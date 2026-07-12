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
  static const int _maxPhotos = 6;

  final _sectionCtrl = TextEditingController();
  final _rowCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final List<String> _photoPaths = []; // local temp paths from picker, before upload
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

  Future<void> _addPhotos() async {
    final picker = ImagePicker();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from library'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    List<String> newPaths = [];
    if (choice == 'camera') {
      final picked = await picker.pickImage(
          source: ImageSource.camera, imageQuality: 70, maxWidth: 1080);
      if (picked != null) newPaths = [picked.path];
    } else {
      final picked = await picker.pickMultiImage(imageQuality: 70, maxWidth: 1080);
      newPaths = picked.map((x) => x.path).toList();
    }
    if (newPaths.isEmpty) return;

    setState(() {
      final remaining = _maxPhotos - _photoPaths.length;
      _photoPaths.addAll(newPaths.take(remaining));
    });

    if (_photoPaths.length >= _maxPhotos && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Up to $_maxPhotos photos per signature.')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
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

      List<String> photoUrls = [];
      if (_photoPaths.isNotEmpty) {
        photoUrls = await StorageService.uploadPhotos(_photoPaths, id);
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
        photoUrls: photoUrls,
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
          _fieldLabel('Photos (optional, up to $_maxPhotos)'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _photoPaths.length; i++)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_photoPaths[i]),
                          width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _removePhoto(i),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: AppColors.red, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_photoPaths.length < _maxPhotos)
                InkWell(
                  onTap: _addPhotos,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo, color: AppColors.green),
                  ),
                ),
            ],
          ),
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