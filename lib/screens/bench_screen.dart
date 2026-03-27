import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/bench_data.dart';
import '../data/item_library.dart';
import '../models/game_models.dart';

class BenchScreen extends StatefulWidget {
  final String userName;
  const BenchScreen({super.key, required this.userName});

  @override
  State<BenchScreen> createState() => _BenchScreenState();
}

class _BenchScreenState extends State<BenchScreen> {
  Map<String, int> _benchStocks = {};
  Map<String, int> _benchLevels = {};
  Timer? _timer; // SERİ ARTIŞ İÇİN ZAMANLAYICI

  String get _benchStockKey => 'bench_stocks_${widget.userName}';
  String get _benchLevelKey => 'bench_levels_${widget.userName}';

  @override
  void dispose() {
    _timer?.cancel(); // EKRAN KAPANIRSA ZAMANLAYICIYI DURDUR
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final stockData = prefs.getString(_benchStockKey);
    final levelData = prefs.getString(_benchLevelKey);
    if (mounted) {
      setState(() {
        if (stockData != null) _benchStocks = Map<String, int>.from(json.decode(stockData));
        if (levelData != null) _benchLevels = Map<String, int>.from(json.decode(levelData));
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_benchStockKey, json.encode(_benchStocks));
    await prefs.setString(_benchLevelKey, json.encode(_benchLevels));
  }

  void _updateStock(String benchId, String itemId, int delta, int max) {
    final key = "${benchId}_$itemId";
    setState(() {
      int current = _benchStocks[key] ?? 0;
      _benchStocks[key] = (current + delta).clamp(0, max);
    });
    _saveData();
  }

  // --- BASILI TUTUNCA ÇALIŞAN MOTOR ---
  void _startTimer(String benchId, String itemId, int delta, int max) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateStock(benchId, itemId, delta, max);
      final key = "${benchId}_$itemId";
      if ((_benchStocks[key] == 0 && delta < 0) || (_benchStocks[key] == max && delta > 0)) {
        _timer?.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _completeLevel(String benchId, BenchLevel level) {
    setState(() {
      _benchLevels[benchId] = level.level;
      for (var req in level.materials) {
        final key = "${benchId}_${req.itemId}";
        _benchStocks[key] = 0; 
      }
    });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.orangeAccent, content: Text("SEVİYE v${level.level} TAMAMLANDI!", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("ATÖLYE")),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: BenchData.allBenches.length,
        itemBuilder: (context, index) => _buildBenchCard(BenchData.allBenches[index], isDark),
      ),
    );
  }

  Widget _buildBenchCard(Bench bench, bool isDark) {
    int defaultLevel = (bench.id == "scrappy") ? 1 : 0;
    int currentLevel = _benchLevels[bench.id] ?? defaultLevel;
    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
          child: Padding(padding: const EdgeInsets.all(4.0), child: Image.asset("assets/images/${bench.id}.png", errorBuilder: (c, e, s) => const Icon(Icons.build_circle, color: Colors.orangeAccent, size: 30))),
        ),
        title: Text(bench.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text("Mevcut Seviye: v$currentLevel"),
        children: bench.levels.map((level) => _buildLevelItem(bench, level, currentLevel, isDark)).toList(),
      ),
    );
  }

  Widget _buildLevelItem(Bench bench, BenchLevel level, int currentLevel, bool isDark) {
    bool isCompleted = level.level <= currentLevel;
    bool isActive = level.level == currentLevel + 1;
    bool isLocked = level.level > currentLevel + 1;
    Color headerColor = isCompleted ? Colors.greenAccent : (isActive ? Colors.orangeAccent : Colors.grey);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02), borderRadius: BorderRadius.circular(10), border: isActive ? Border.all(color: Colors.orangeAccent.withOpacity(0.3)) : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("v${level.level} Geliştirme", style: TextStyle(color: headerColor, fontWeight: FontWeight.bold, fontSize: 14)),
              if (isCompleted) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
              if (isLocked) const Icon(Icons.lock_outline, color: Colors.grey, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          ...level.materials.map((req) {
            final key = "${bench.id}_${req.itemId}";
            int current = _benchStocks[key] ?? 0;
            GameItem? item;
            try { item = ItemLibrary.resourceItems.firstWhere((i) => i.id == req.itemId); } catch (e) { item = null; }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Opacity(opacity: isActive ? 1.0 : 0.4, child: SizedBox(width: 30, height: 30, child: Image.asset("assets/items/${item?.fileName ?? 'logo.webp'}", errorBuilder: (c, e, s) => const Icon(Icons.help_outline)))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item?.nameTr ?? req.itemId, style: TextStyle(fontSize: 13, color: isActive ? (isDark ? Colors.white : Colors.black87) : Colors.grey))),
                  Row(
                    children: [
                      _buildMiniBtn(Icons.remove, isActive ? () => _updateStock(bench.id, req.itemId, -1, req.quantity) : null, isDark, active: isActive, onLongPressStart: isActive ? (d) => _startTimer(bench.id, req.itemId, -1, req.quantity) : null, onLongPressEnd: isActive ? (d) => _stopTimer() : null),
                      const SizedBox(width: 8),
                      Text(isCompleted ? "${req.quantity} / ${req.quantity}" : "$current / ${req.quantity}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isCompleted ? Colors.greenAccent : (isActive && current >= req.quantity ? Colors.greenAccent : Colors.grey))),
                      const SizedBox(width: 8),
                      _buildMiniBtn(Icons.add, isActive ? () => _updateStock(bench.id, req.itemId, 1, req.quantity) : null, isDark, color: Colors.greenAccent, active: isActive, onLongPressStart: isActive ? (d) => _startTimer(bench.id, req.itemId, 1, req.quantity) : null, onLongPressEnd: isActive ? (d) => _stopTimer() : null),
                    ],
                  )
                ],
              ),
            );
          }),
          if (isActive) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 35, child: ElevatedButton(onPressed: (level.materials.every((m) => (_benchStocks["${bench.id}_${m.itemId}"] ?? 0) >= m.quantity)) ? () => _completeLevel(bench.id, level) : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))), child: const Text("SEVİYE ATLA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))))
          ]
        ],
      ),
    );
  }

  Widget _buildMiniBtn(IconData icon, VoidCallback? onTap, bool isDark, {Color? color, bool active = true, void Function(LongPressStartDetails)? onLongPressStart, void Function(LongPressEndDetails)? onLongPressEnd}) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: active ? (isDark ? Colors.white10 : Colors.black12) : Colors.transparent, borderRadius: BorderRadius.circular(5)), child: Icon(icon, size: 16, color: active ? (color ?? (isDark ? Colors.white70 : Colors.black54)) : Colors.grey.withOpacity(0.3))),
    );
  }
}
