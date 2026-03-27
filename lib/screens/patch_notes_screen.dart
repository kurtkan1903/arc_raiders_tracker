import 'package:flutter/material.dart';
import '../patches/patch_manager.dart';
import '../models/patch_note.dart';

class PatchNotesScreen extends StatelessWidget {
  const PatchNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patches = PatchManager.allPatches;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("BÖLGE RAPORLARI (PATCH NOTES)"),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blueAccent.withOpacity(0.1),
            child: const Text(
              "SPERANZA VERİ MERKEZİNDEN GELEN SON GÜNCELLEMELER",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: patches.length,
              itemBuilder: (context, index) {
                final patch = patches[index];
                return _patchButton(context, patch);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _patchButton(BuildContext context, PatchNote patch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPatchDetail(context, patch),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: Colors.blueAccent),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Patch Notları ${patch.version}", 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(patch.date, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatchDetail(BuildContext context, PatchNote patch) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4, 
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("v${patch.version}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24)),
                  Text(patch.date, style: const TextStyle(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 10),
              Text(patch.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),
              const Text("GÜNCELLEME İÇERİĞİ:", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: patch.content.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(color: Colors.blueAccent, fontSize: 18)),
                        Expanded(child: Text(patch.content[index], style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5))),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.black),
                  child: const Text("ANLAŞILDI"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
