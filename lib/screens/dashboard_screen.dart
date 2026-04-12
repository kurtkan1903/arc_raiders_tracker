import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'resource_screen.dart';
import 'blueprint_screen.dart';
import 'bench_screen.dart';
import 'mission_screen.dart';
import 'settings_screen.dart';
import '../data/bench_data.dart';
import '../data/mission_data.dart';
import '../data/item_repository.dart';
import '../models/game_models.dart';
import '../services/updater_service.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _benchProgressPercent = 0;
  double _missionProgressPercent = 0;

  @override
  void initState() {
    super.initState();
    _calculateOverallProgress();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdaterService.checkForUpdates(context);
    });
  }

  Future<void> _calculateOverallProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    final benchLevels = Map<String, int>.from(json.decode(prefs.getString('bench_levels_${widget.userName}') ?? '{}'));
    int totalBenchLevels = 0;
    int completedBenchLevels = 0;
    for (var bench in BenchData.allBenches) {
      totalBenchLevels += bench.levels.length;
      completedBenchLevels += benchLevels[bench.id] ?? (bench.id == "scrappy" ? 1 : 0);
    }
    
    final missionStages = Map<String, int>.from(json.decode(prefs.getString('mission_stages_${widget.userName}') ?? '{}'));
    int totalMissionStages = 0;
    int completedMissionStages = 0;
    for (var mission in MissionData.allMissions) {
      if (mission.isLocked) continue;
      totalMissionStages += mission.stages.length;
      completedMissionStages += missionStages[mission.name] ?? 0;
    }

    if (mounted) {
      setState(() {
        _benchProgressPercent = totalBenchLevels > 0 ? (completedBenchLevels / totalBenchLevels) * 100 : 0;
        _missionProgressPercent = totalMissionStages > 0 ? (completedMissionStages / totalMissionStages) * 100 : 0;
      });
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            Text("OPERASYON MERKEZİ", style: GoogleFonts.inter(letterSpacing: 4, fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.userName.toUpperCase(), style: GoogleFonts.inter(letterSpacing: 2, fontSize: 18, fontWeight: FontWeight.w900, color: Colors.purpleAccent)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white24),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(userName: widget.userName)));
              _calculateOverallProgress();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _speranzaBroadcastTicker(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _buildProgressGrid(),
                  const SizedBox(height: 25),
                  _sectionHeader("SİSTEM VERİLERİ (HUD)"),
                  const SizedBox(height: 15),
                  _hudMenuBtn(context, "İTEM TABANI", "Speranza nesne arşivi", Icons.category_outlined, Colors.purpleAccent, ResourceScreen(userName: widget.userName)),
                  _hudMenuBtn(context, "ATÖLYE MODÜLLERİ", "Üretim ve geliştirme", Icons.handyman_outlined, Colors.orangeAccent, BenchScreen(userName: widget.userName), progress: _benchProgressPercent),
                  _hudMenuBtn(context, "RAIDER PROJELERİ", "Sefer ve görev takibi", Icons.map_outlined, Colors.greenAccent, MissionScreen(userName: widget.userName), progress: _missionProgressPercent),
                  _hudMenuBtn(context, "HIZLI ÜRETİM", "Blueprint ve modüller", Icons.inventory_2_outlined, Colors.blueAccent, BlueprintScreen(userName: widget.userName)),
                  
                  const SizedBox(height: 25),
                  _sectionHeader("TAKTIK HAZIRLIK"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _tacticalPrepBtn(context, "ATÖLYE", Icons.build_circle_outlined, Colors.orangeAccent, true)),
                      const SizedBox(width: 15),
                      Expanded(child: _tacticalPrepBtn(context, "PROJELER", Icons.rocket_launch_outlined, Colors.greenAccent, false)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Opacity(
                    opacity: 0.1,
                    child: Image.asset("assets/images/logo.webp", width: 100),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildProgressMini("BENCH SYNCHRONIZATION", _benchProgressPercent, Colors.purpleAccent),
              const SizedBox(height: 20),
              _buildProgressMini("MISSION DEPLOYMENT", _missionProgressPercent, Colors.orangeAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressMini(String title, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: color.withOpacity(0.6), letterSpacing: 1)),
            Text("%${percent.toInt()}", style: GoogleFonts.inter(fontSize: 14, color: Colors.white24)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(2))),
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              height: 4,
              width: (MediaQuery.of(context).size.width - 100) * (percent / 100),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _speranzaBroadcastTicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withOpacity(0.05),
        border: Border.symmetric(horizontal: BorderSide(color: Colors.purpleAccent.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 20),
            const Icon(Icons.sensors, color: Colors.purpleAccent, size: 14),
            const SizedBox(width: 10),
            Text("SPERANZA BROADCAST:", style: GoogleFonts.inter(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
            const SizedBox(width: 10),
            Text("BÖLGEDE ARC YOĞUNLUĞU NORMAL... YENİ NESNELER TANIMLANDI... OPERASYON MERKEZİ AKTİF...", 
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: Colors.purpleAccent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.inter(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 11)),
        const Expanded(child: Divider(indent: 15, color: Colors.white10)),
      ],
    );
  }

  Widget _hudMenuBtn(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget target, {double? progress}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => target));
          _calculateOverallProgress();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.08)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.1)),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: GoogleFonts.inter(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                if (progress != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("%${progress.toStringAsFixed(0)}", style: GoogleFonts.inter(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("SYNC", style: GoogleFonts.inter(color: Colors.white10, fontSize: 7, fontWeight: FontWeight.bold)),
                    ],
                  ),
                const SizedBox(width: 12),
                Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tacticalPrepBtn(BuildContext context, String title, IconData icon, Color color, bool isBench) {
    return InkWell(
      onTap: () => _calculateNeeds(context, isBench: isBench),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 12),
                Text(title, style: GoogleFonts.inter(color: color.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text("SCAN MODULES", style: GoogleFonts.inter(color: Colors.white12, fontSize: 7, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _calculateNeeds(BuildContext context, {required bool isBench}) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, int> totalItemNeeds = {};
    Map<String, int> totalCoinNeeds = {};

    if (isBench) {
      final benchStocks = Map<String, int>.from(json.decode(prefs.getString('bench_stocks_${widget.userName}') ?? '{}'));
      final benchLevels = Map<String, int>.from(json.decode(prefs.getString('bench_levels_${widget.userName}') ?? '{}'));
      
      for (var bench in BenchData.allBenches) {
        int currentLevel = benchLevels[bench.id] ?? (bench.id == "scrappy" ? 1 : 0);
        BenchLevel? activeLevel;
        try {
          activeLevel = bench.levels.firstWhere((lvl) => lvl.level == currentLevel + 1);
        } catch (e) {
          activeLevel = null;
        }

        if (activeLevel != null) {
          for (var mat in activeLevel.materials) {
            final key = "${bench.id}_${mat.itemId}";
            int current = benchStocks[key] ?? 0;
            if (current < mat.quantity) {
              totalItemNeeds[mat.itemId] = (totalItemNeeds[mat.itemId] ?? 0) + (mat.quantity - current);
            }
          }
        }
      }
    } else {
      final missionProgress = Map<String, int>.from(json.decode(prefs.getString('mission_progress_${widget.userName}') ?? '{}'));
      final missionStages = Map<String, int>.from(json.decode(prefs.getString('mission_stages_${widget.userName}') ?? '{}'));
      
      for (int i = 0; i < MissionData.allMissions.length; i++) {
        final mission = MissionData.allMissions[i];
        if (mission.isLocked) continue;

        if (i > 0) {
          final prevMission = MissionData.allMissions[i - 1];
          int prevComp = missionStages[prevMission.name] ?? 0;
          if (prevComp < prevMission.stages.length) break; 
        }

        int completedStages = missionStages[mission.name] ?? 0;
        if (completedStages < mission.stages.length) {
          final activeStage = mission.stages[completedStages];
          for (var req in activeStage.requirements) {
            final key = "${mission.name}_${activeStage.name}_${req.id}";
            int current = missionProgress[key] ?? 0;
            if (current < req.requiredAmount) {
              int missing = req.requiredAmount - current;
              if (req.type == RequirementType.item) {
                totalItemNeeds[req.id] = (totalItemNeeds[req.id] ?? 0) + missing;
              } else {
                String label = req.displayName ?? req.id;
                totalCoinNeeds[label] = (totalCoinNeeds[label] ?? 0) + missing;
              }
            }
          }
          break;
        }
      }
    }

    if (context.mounted) {
      _showNeedsDialog(context, totalItemNeeds, totalCoinNeeds, isDark, isBench ? "ATÖLYE EKSİKLERİ" : "PROJE EKSİKLERİ");
    }
  }

  void _shareNeeds(String title, Map<String, int> items, Map<String, int> coins) {
    final List<String> lines = ["ARC Raiders Tracker - $title (${widget.userName}):\n"];
    if (items.isNotEmpty) {
      lines.add("* TOPLANACAK EŞYALAR:");
      for (var e in items.entries) {
        final item = ItemRepository.resourceItems.firstWhere((i) => i.id == e.key, orElse: () => GameItem(id: e.key, nameTr: ""));
        lines.add("  - ${_capitalize(item.displayName)}: ${e.value} adet");
      }
      lines.add("");
    }
    if (coins.isNotEmpty) {
      lines.add("* GEREKLİ BÜTÇE:");
      for (var e in coins.entries) {
        String val = e.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
        lines.add("  - ${_capitalize(e.key)}: $val Coin");
      }
    }
    if (items.isEmpty && coins.isEmpty) lines.add("Şu an için hiçbir eksik bulunmuyor! 🛡️");
    Share.share(lines.join("\n"), subject: title);
  }

  void _showNeedsDialog(BuildContext context, Map<String, int> items, Map<String, int> coins, bool isDark, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3))),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, color: Colors.orangeAccent),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 20, color: Colors.orangeAccent),
              onPressed: () => _shareNeeds(title, items, coins),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: items.isEmpty && coins.isEmpty
              ? const Text("Harika! Bu kategori için hiçbir eksiğin yok. 🛡️", textAlign: TextAlign.center, style: TextStyle(color: Colors.greenAccent))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (items.isNotEmpty) ...[
                        const Text("GEREKLİ MALZEMELER", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        ...items.entries.map((e) {
                          final item = ItemRepository.resourceItems.firstWhere((i) => i.id == e.key, orElse: () => GameItem(id: e.key, nameTr: ""));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right, color: Colors.white24, size: 16),
                                Expanded(child: Text("${_capitalize(item.displayName)}", style: const TextStyle(color: Colors.white70, fontSize: 13))),
                                Text("${e.value}x", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],
                      if (coins.isNotEmpty) ...[
                        const Text("GEREKLİ BÜTÇE", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        ...coins.entries.map((e) {
                          String val = e.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.monetization_on_outlined, color: Colors.yellowAccent, size: 14),
                                const SizedBox(width: 5),
                                Expanded(child: Text("${_capitalize(e.key)}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13))),
                                Text("$val", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("KAPAT", style: TextStyle(color: Colors.orangeAccent))),
        ],
      ),
    );
  }
}
