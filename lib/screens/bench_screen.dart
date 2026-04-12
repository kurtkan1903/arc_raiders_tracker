import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/bench_data.dart';
import '../data/item_repository.dart';
import '../models/game_models.dart';
import '../widgets/item_image.dart';

class BenchScreen extends StatefulWidget {
  final String userName;
  const BenchScreen({super.key, required this.userName});

  @override
  State<BenchScreen> createState() => _BenchScreenState();
}

class _BenchScreenState extends State<BenchScreen> {
  Map<String, int> _benchStocks = {};
  Map<String, int> _benchLevels = {};
  Set<String> _expandedBenches = {}; // AÇIK OLAN TEZGAHLARI TUTAR
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
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      appBar: AppBar(
        title: Text("SİSTEM GELİŞTİRMELERİ", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: BenchData.allBenches.length,
        itemBuilder: (context, index) {
          final bench = BenchData.allBenches[index];
          return _buildModernBenchCard(bench);
        },
      ),
    );
  }

  Widget _buildModernBenchCard(Bench bench) {
    int currentLevel = _benchLevels[bench.id] ?? (bench.id == "scrappy" ? 1 : 0);
    bool isFullyUpgraded = currentLevel >= bench.levels.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (_expandedBenches.contains(bench.id)) {
                      _expandedBenches.remove(bench.id);
                    } else {
                      _expandedBenches.add(bench.id);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.purpleAccent.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.architecture_outlined, color: Colors.purpleAccent, size: 24),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bench.name.toUpperCase(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text(isFullyUpgraded ? "MODULE FULLY OPTIMIZED" : "HARDWARE DETAILS", 
                              style: GoogleFonts.inter(color: Colors.white12, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      _levelBadge(currentLevel),
                      const SizedBox(width: 10),
                      Icon(
                        _expandedBenches.contains(bench.id) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white24,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  child: _expandedBenches.contains(bench.id) 
                    ? Column(
                        children: bench.levels.map((level) {
                          bool isCompleted = currentLevel >= level.level;
                          bool isActive = currentLevel == level.level - 1;
                          bool isLocked = currentLevel < level.level - 1;
                          
                          return Column(
                            children: [
                              const Divider(color: Colors.white10, height: 1),
                              _buildLevelHeader(level, isCompleted, isActive, isLocked),
                              if (!isCompleted) _buildLevelRequirements(bench, level, isLocked),
                              if (isCompleted) 
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                                      const SizedBox(width: 10),
                                      Text("BU SEVİYE TAMAMLANDI", style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      )
                    : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelHeader(BenchLevel level, bool isCompleted, bool isActive, bool isLocked) {
    Color statusColor = isActive ? Colors.purpleAccent : (isCompleted ? Colors.greenAccent : Colors.white24);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Text("SEVİYE v${level.level.toString().padLeft(2, '0')}", 
            style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const Spacer(),
          if (isLocked) const Icon(Icons.lock_outline, color: Colors.white12, size: 14),
          if (isCompleted) const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
        ],
      ),
    );
  }

  Widget _levelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.1)),
      ),
      child: Text("v${level.toString().padLeft(2, '0')}", style: GoogleFonts.inter(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLevelRequirements(Bench bench, BenchLevel level, bool isLocked) {
    bool allMet = true;
    for (var req in level.materials) {
      if ((_benchStocks["${bench.id}_${req.itemId}"] ?? 0) < req.quantity) allMet = false;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("GEREKLİ BİLEŞENLER", style: GoogleFonts.inter(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 15),
          ...level.materials.map((req) => _buildReqRow(bench, req, isLocked)),
          const SizedBox(height: 15),
          if (!isLocked)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: allMet ? () => _completeLevel(bench.id, level) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allMet ? Colors.purpleAccent : Colors.white.withOpacity(0.03),
                  foregroundColor: allMet ? Colors.black : Colors.white12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: allMet ? 8 : 0,
                  shadowColor: Colors.purpleAccent.withOpacity(0.5),
                ),
                child: Text(allMet ? "GELİŞTİRMEYİ ONAYLA" : "BİLEŞENLER EKSİK", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReqRow(Bench bench, RequiredMaterial req, bool isLocked) {
    final item = ItemRepository.findById(req.itemId);
    final current = _benchStocks["${bench.id}_${req.itemId}"] ?? 0;
    final bool isDone = current >= req.quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
                child: ItemImage(item: item, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item?.displayName ?? req.itemId, style: GoogleFonts.inter(color: isLocked ? Colors.white24 : (isDone ? Colors.white70 : Colors.white38), fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text("$current / ${req.quantity}", style: GoogleFonts.inter(color: isLocked ? Colors.white10 : (isDone ? Colors.greenAccent : Colors.orangeAccent), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (!isLocked) ...[
                _stockButton(Icons.remove, () => _updateStock(bench.id, req.itemId, -1, req.quantity), isLocked),
                const SizedBox(width: 8),
                _stockButton(Icons.add, () => _updateStock(bench.id, req.itemId, 1, req.quantity), isLocked),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(height: 3, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                width: (MediaQuery.of(context).size.width - 70) * (current / req.quantity).clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.white12 : (isDone ? Colors.greenAccent : Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockButton(IconData icon, VoidCallback onTap, bool isLocked) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isLocked ? Colors.white.withOpacity(0.02) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isLocked ? Colors.transparent : Colors.white10),
        ),
        child: Icon(icon, color: isLocked ? Colors.white12 : Colors.white70, size: 16),
      ),
    );
  }
}
