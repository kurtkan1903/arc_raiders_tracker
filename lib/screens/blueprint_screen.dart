import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../data/item_library.dart';
import '../models/game_models.dart';

class BlueprintScreen extends StatefulWidget {
  final String userName;
  const BlueprintScreen({super.key, required this.userName});

  @override
  State<BlueprintScreen> createState() => _BlueprintScreenState();
}

class _BlueprintScreenState extends State<BlueprintScreen> {
  Map<String, int> bpStocks = {};
  String searchQuery = "";
  List<GameItem> _sortedBlueprintItems = [];
  Timer? _timer;
  bool _showOnlyOwned = false;

  String get _storageKey => 'blueprint_inventory_${widget.userName}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBPStocks();
    _sortBlueprintItems();
  }

  void _sortBlueprintItems() {
    const turkishAlphabet = "abcçdefgğhıijklmnoöprsştuüvyz";
    // Filtreyi tamamen kaldırdık çünkü kütüphanede zaten sadece Mk III'ler var.
    _sortedBlueprintItems = List.from(ItemLibrary.blueprintItems);

    _sortedBlueprintItems.sort((a, b) {
      String nameA = a.nameTr.toLowerCase();
      String nameB = b.nameTr.toLowerCase();
      int len = nameA.length < nameB.length ? nameA.length : nameB.length;
      for (int i = 0; i < len; i++) {
        int indexA = turkishAlphabet.indexOf(nameA[i]);
        int indexB = turkishAlphabet.indexOf(nameB[i]);
        if (indexA != -1 && indexB != -1) {
          if (indexA != indexB) return indexA.compareTo(indexB);
        } else {
          final int compare = nameA[i].compareTo(nameB[i]);
          if (compare != 0) return compare;
        }
      }
      return nameA.length.compareTo(nameB.length);
    });
  }

  Future<void> _loadBPStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_storageKey);
    if (savedData != null && mounted) {
      setState(() {
        bpStocks = Map<String, int>.from(json.decode(savedData));
      });
    }
  }

  Future<void> _saveBPStocks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(bpStocks));
  }

  void _changeStock(String id, int delta) {
    setState(() {
      int current = bpStocks[id] ?? 0;
      bpStocks[id] = (current + delta).clamp(0, 999);
    });
    _saveBPStocks();
  }

  void _startTimer(String id, int delta) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final current = bpStocks[id] ?? 0;
      if ((delta > 0 && current < 999) || (delta < 0 && current > 0)) {
        _changeStock(id, delta);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _shareBlueprints() {
    final List<String> ownedBps = [];
    for (var item in _sortedBlueprintItems) {
      final count = bpStocks[item.id] ?? 0;
      if (count > 0) {
        ownedBps.add("- ${item.nameTr} (x$count)");
      }
    }

    if (ownedBps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paylaşılacak herhangi bir blueprint'e sahip değilsiniz.")));
      return;
    }

    final String textToShare = "ARC Raiders - Blueprint Listem (${widget.userName}):\n\n${ownedBps.join('\n')}";
    Share.share(textToShare, subject: "ARC Raiders Blueprint Listem");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredBlueprints = _sortedBlueprintItems.where((item) {
      final matchesSearch = item.nameTr.toLowerCase().contains(searchQuery.toLowerCase());
      final isOwned = (bpStocks[item.id] ?? 0) > 0;
      return _showOnlyOwned ? (matchesSearch && isOwned) : matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("BLUEPRINT DEPOSU"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_showOnlyOwned ? Icons.filter_alt : Icons.filter_alt_outlined, color: Colors.blueAccent),
            onPressed: () => setState(() => _showOnlyOwned = !_showOnlyOwned),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.blueAccent),
            onPressed: _shareBlueprints,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "İsimle ara...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: filteredBlueprints.isEmpty 
        ? Center(
            child: Text(
              _showOnlyOwned ? "Henüz hiçbir şemaya sahip değilsiniz." : "Aradığınız şema bulunamadı.",
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            ),
          )
        : ListView.builder(
            itemCount: filteredBlueprints.length,
            itemBuilder: (context, index) {
              final item = filteredBlueprints[index];
              final count = bpStocks[item.id] ?? 0;
              final displayIndex = (index + 1).toString().padLeft(2, '0');
              return _buildBPItem(item, count, isDark, displayIndex);
            },
          ),
    );
  }

  Widget _buildBPItem(GameItem item, int count, bool isDark, String indexStr) {
    final bool hasOwned = count > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasOwned ? Colors.orangeAccent.withOpacity(0.6) : (isDark ? Colors.white10 : Colors.grey[300]!),
          width: hasOwned ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(indexStr, style: const TextStyle(color: Colors.white12, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(width: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/Bp_background.webp", width: 45, height: 45, errorBuilder: (c, e, s) => Container(width: 45, height: 45, color: Colors.white10)),
                Image.asset("assets/blueprints/${item.fileName}", width: 30, height: 30, errorBuilder: (c, e, s) => const Icon(Icons.description, color: Colors.blueAccent)),
              ],
            ),
          ],
        ),
        title: Text(item.nameTr.toUpperCase(), style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87, fontWeight: hasOwned ? FontWeight.bold : FontWeight.normal)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _countBtn(Icons.remove, () => _changeStock(item.id, -1), (d) => _startTimer(item.id, -1), (d) => _stopTimer()),
            SizedBox(width: 30, child: Center(child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 14)))),
            _countBtn(Icons.add, () => _changeStock(item.id, 1), (d) => _startTimer(item.id, 1), (d) => _stopTimer()),
          ],
        ),
      ),
    );
  }

  Widget _countBtn(IconData i, VoidCallback t, void Function(LongPressStartDetails)? s, void Function(LongPressEndDetails)? e) {
    return GestureDetector(
      onTap: t, onLongPressStart: s, onLongPressEnd: e,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
        child: Icon(i, color: Colors.blueAccent, size: 16),
      ),
    );
  }
}
