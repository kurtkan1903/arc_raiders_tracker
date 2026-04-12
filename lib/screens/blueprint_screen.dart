import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/item_repository.dart';
import '../models/game_models.dart';
import '../widgets/item_image.dart';

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
    _refreshItems();
  }

  void _refreshItems() {
    setState(() {
      _sortedBlueprintItems = ItemRepository.blueprintItems;
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

  void _start_timer(String id, int delta) {
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

  void _stop_timer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBlueprints = _sortedBlueprintItems.where((item) {
      final matchesSearch = item.displayName.toLowerCase().contains(searchQuery.toLowerCase());
      final isOwned = (bpStocks[item.id] ?? 0) > 0;
      return _showOnlyOwned ? (matchesSearch && isOwned) : matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("B.P. ENVANTERİ", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: Icon(_showOnlyOwned ? Icons.filter_alt : Icons.filter_alt_outlined, color: Colors.blueAccent),
            onPressed: () => setState(() => _showOnlyOwned = !_showOnlyOwned),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "SİSTEMDE ARA...",
                      hintStyle: GoogleFonts.inter(color: Colors.white10, fontSize: 10, letterSpacing: 1),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: filteredBlueprints.length,
        itemBuilder: (context, index) {
          final item = filteredBlueprints[index];
          final count = bpStocks[item.id] ?? 0;
          final displayIndex = (index + 1).toString().padLeft(2, '0');
          return _buildModernBPItem(item, count, displayIndex);
        },
      ),
    );
  }

  Widget _buildModernBPItem(GameItem item, int count, String indexStr) {
    final bool hasOwned = count > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasOwned ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.03),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(indexStr, style: GoogleFonts.inter(color: Colors.white10, fontSize: 10)),
                const SizedBox(width: 15),
                Container(
                  width: 80, height: 80,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ItemImage(item: item, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.displayName.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, color: hasOwned ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text("BLUEPRINT MODULE", style: GoogleFonts.inter(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _countControl(item, count),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _countControl(GameItem item, int count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _countBtn(Icons.remove, () => _changeStock(item.id, -1), (d) => _start_timer(item.id, -1), (d) => _stop_timer()),
          SizedBox(
            width: 35,
            child: Center(
              child: Text("$count", style: GoogleFonts.inter(color: count > 0 ? Colors.blueAccent : Colors.white24, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          _countBtn(Icons.add, () => _changeStock(item.id, 1), (d) => _start_timer(item.id, 1), (d) => _stop_timer()),
        ],
      ),
    );
  }

  Widget _buildItemImage(GameItem item) {
    return ItemImage(item: item, fit: BoxFit.cover);
  }

  Widget _countBtn(IconData i, VoidCallback t, void Function(LongPressStartDetails)? s, void Function(LongPressEndDetails)? e) {
    return GestureDetector(
      onTap: t, onLongPressStart: s, onLongPressEnd: e,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Icon(i, color: Colors.blueAccent.withOpacity(0.5), size: 16),
      ),
    );
  }
}
