import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'blueprint_screen.dart';
import 'bench_screen.dart';
import 'mission_screen.dart';
import 'settings_screen.dart';
import '../data/bench_data.dart';
import '../data/mission_data.dart';
import '../data/item_library.dart';
import '../models/game_models.dart';
import '../services/updater_service.dart'; // YENİ SERVİS EKLENDİ

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
    
    // UYGULAMA AÇILIŞINDA GÜNCELLEME KONTROLÜ YAP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdaterService.checkForUpdates(context);
    });
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
    final List<String> lines = ["ARC Raider Tracker - $title (${widget.userName}):\n"];
    
    if (items.isNotEmpty) {
      lines.add("* TOPLANACAK EŞYALAR:");
      for (var e in items.entries) {
        final item = ItemLibrary.resourceItems.firstWhere((i) => i.id == e.key, orElse: () => GameItem(id: e.key, nameTr: e.key, fileName: ""));
        lines.add("  - ${_capitalize(item.nameTr)}: ${e.value} adet");
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

    if (items.isEmpty && coins.isEmpty) {
      lines.add("Şu an için hiçbir eksik bulunmuyor! 🛡️");
    }

    Share.share(lines.join("\n"), subject: title);
  }

  void _showNeedsDialog(BuildContext context, Map<String, int> items, Map<String, int> coins, bool isDark, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3))),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, color: Colors.orangeAccent),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
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
                          final item = ItemLibrary.resourceItems.firstWhere((i) => i.id == e.key, orElse: () => GameItem(id: e.key, nameTr: e.key, fileName: ""));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_right, color: Colors.white24, size: 16),
                                Expanded(child: Text("${_capitalize(item.nameTr)}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13))),
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("HOŞGELDİN, ${widget.userName.toUpperCase()}", style: const TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(userName: widget.userName)));
              _calculateOverallProgress();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _menuBtn(context, "BLUEPRINT", Icons.inventory_2_outlined, Colors.blueAccent, BlueprintScreen(userName: widget.userName)),
            _menuBtn(context, "ATÖLYE", Icons.handyman_outlined, Colors.orangeAccent, BenchScreen(userName: widget.userName), progress: _benchProgressPercent),
            _menuBtn(context, "RAİDERS PROJELERİ", Icons.map_outlined, Colors.greenAccent, MissionScreen(userName: widget.userName), progress: _missionProgressPercent),
            
            const SizedBox(height: 30),
            const Divider(color: Colors.white10, thickness: 1),
            const SizedBox(height: 10),
            const Text("OPERASYON HAZIRLIĞI", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 10)),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _prepBtn(context, "ATÖLYE", Icons.build_circle_outlined, Colors.orangeAccent, true)),
                const SizedBox(width: 15),
                Expanded(child: _prepBtn(context, "PROJELER", Icons.rocket_launch_outlined, Colors.greenAccent, false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _prepBtn(BuildContext context, String title, IconData icon, Color color, bool isBench) {
    return InkWell(
      onTap: () => _calculateNeeds(context, isBench: isBench),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            const Text("EKSİKLERİ TARA", style: TextStyle(color: Colors.white24, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _menuBtn(BuildContext context, String title, IconData icon, Color color, Widget? targetScreen, {double? progress}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        leading: Icon(icon, color: color, size: 28),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
            if (progress != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: Text("%${progress.toStringAsFixed(0)}", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white10, size: 20),
        onTap: () async {
          if (targetScreen != null) {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
            _calculateOverallProgress();
          }
        },
      ),
    );
  }
}
