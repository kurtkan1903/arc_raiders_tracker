import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../data/item_library.dart';
import '../data/mission_data.dart';
import '../models/game_models.dart';

class MissionScreen extends StatefulWidget {
  final String userName;
  const MissionScreen({super.key, required this.userName});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  Map<String, int> _missionProgress = {};
  Map<String, int> _missionStages = {};
  Timer? _timer;
  bool _isPopupShowing = false;

  String get _progressKey => 'mission_progress_${widget.userName}';
  String get _stageKey => 'mission_stages_${widget.userName}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getString(_progressKey);
    final stageData = prefs.getString(_stageKey);
    if (mounted) {
      setState(() {
        if (progressData != null) _missionProgress = Map<String, int>.from(json.decode(progressData));
        if (stageData != null) _missionStages = Map<String, int>.from(json.decode(stageData));
      });
      _forceCheckAllStages(showPopup: false);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, json.encode(_missionProgress));
    await prefs.setString(_stageKey, json.encode(_missionStages));
  }

  void _changeRequirementCount(MissionRequirement req, String missionName, String stageName, int stageNumber, int delta) {
    final key = "${missionName}_${stageName}_${req.id}";
    setState(() {
      int current = _missionProgress[key] ?? 0;
      int step;
      if (req.type == RequirementType.coin) {
        if (stageNumber == 6 && req.requiredAmount >= 500000) {
          step = (delta.abs() >= 10) ? 500000 : 100000;
        } else {
          step = (delta.abs() >= 10) ? 100000 : 10000;
        }
      } else {
        step = 1;
      }
      _missionProgress[key] = (current + (delta.sign * step)).clamp(0, req.requiredAmount);
    });
    _forceCheckAllStages(showPopup: true);
    _saveData();
  }

  // --- HIZLI TAMAMLAMA MOTORU ---
  void _quickCompleteMission(Mission mission) {
    setState(() {
      for (var stage in mission.stages) {
        for (var req in stage.requirements) {
          final key = "${mission.name}_${stage.name}_${req.id}";
          _missionProgress[key] = req.requiredAmount;
        }
      }
      _missionStages[mission.name] = mission.stages.length;
    });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("${mission.name} başarıyla tamamlandı! 🛡️")),
    );
  }

  void _startTimer(MissionRequirement req, String missionName, String stageName, int stageNumber, int delta) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _changeRequirementCount(req, missionName, stageName, stageNumber, delta);
      final key = "${missionName}_${stageName}_${req.id}";
      if ((_missionProgress[key] == 0 && delta < 0) || (_missionProgress[key] == req.requiredAmount && delta > 0)) {
        _timer?.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _forceCheckAllStages({required bool showPopup}) {
    bool anyChanged = false;
    for (var mission in MissionData.allMissions) {
      if (mission.isLocked) continue;
      int currentCompleted = 0;
      for (var stage in mission.stages) {
        bool stageComplete = stage.requirements.every((req) {
          final key = "${mission.name}_${stage.name}_${req.id}";
          return (_missionProgress[key] ?? 0) >= req.requiredAmount;
        });
        if (stageComplete) {
          currentCompleted = stage.stageNumber;
        } else {
          break;
        }
      }
      int oldCompleted = _missionStages[mission.name] ?? 0;
      if (oldCompleted != currentCompleted) {
        _missionStages[mission.name] = currentCompleted;
        anyChanged = true;
        if (showPopup && currentCompleted == mission.stages.length && !_isPopupShowing) {
          _showCompletionDialog(mission.name);
        }
      }
    }
    if (anyChanged) setState(() {});
  }

  void _showCompletionDialog(String missionName) {
    _isPopupShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.orangeAccent, width: 2)),
        title: const Column(children: [Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 40), SizedBox(height: 10), Text("OPERASYON TAMAM!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$missionName için tüm aşamaları başarıyla tamamladın.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            const Text("Şimdi sefere çıkmaya hazırsın Raiders!", textAlign: TextAlign.center, style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: ElevatedButton(onPressed: () { _isPopupShowing = false; Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black), child: const Text("ANLAŞILDI", style: TextStyle(fontWeight: FontWeight.bold)))))]
      ),
    );
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_stageKey);
    if (mounted) {
      setState(() { _missionProgress = {}; _missionStages = {}; });
      _forceCheckAllStages(showPopup: false);
    }
  }

  void _showResetDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text("Sıfırla?", style: TextStyle(color: Colors.white)), content: const Text("Tüm ilerleme silinecek. Emin misin?", style: TextStyle(color: Colors.white70)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL")), TextButton(onPressed: () { Navigator.pop(context); _resetData(); }, child: const Text("SIFIRLA", style: TextStyle(color: Colors.red)))]));
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("RAİDERS PROJELERİ"), backgroundColor: Colors.transparent, actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.redAccent), onPressed: _showResetDialog)]),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: MissionData.allMissions.length,
        itemBuilder: (context, index) {
          final mission = MissionData.allMissions[index];
          bool isEnabled = true;
          if (index > 0) {
            final prev = MissionData.allMissions[index - 1];
            if ((_missionStages[prev.name] ?? 0) < prev.stages.length) isEnabled = false;
          }
          return _buildMissionCard(mission, isDark, isEnabled);
        },
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, bool isDark, bool isEnabled) {
    if (mission.isLocked) return _buildLockedCard(mission, isDark, "Çok Yakında...");
    if (!isEnabled) return _buildLockedCard(mission, isDark, "Önceki Seferi Tamamla!");
    int completed = _missionStages[mission.name] ?? 0;
    
    return Card(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ExpansionTile(
        leading: Image.asset(mission.imagePath, width: 60),
        title: Text(mission.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text("Tamamlanan Aşama: $completed / ${mission.stages.length}", style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HIZLI TAMAMLAMA BUTONU (CHECK)
            if (completed < mission.stages.length)
              IconButton(
                icon: const Icon(Icons.check_box_outlined, color: Colors.greenAccent, size: 22),
                onPressed: () => _showQuickCompleteDialog(mission),
                tooltip: "Bu seferi otomatik tamamla",
              ),
            IconButton(
              icon: const Icon(Icons.share, size: 20, color: Colors.greenAccent),
              onPressed: () => _shareSingleMissionProgress(mission),
            ),
          ],
        ),
        children: mission.stages.map((stage) => _buildStageTile(mission, stage, isDark)).toList(),
      ),
    );
  }

  void _showQuickCompleteDialog(Mission mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text("${mission.name} Tamamlansın mı?", style: const TextStyle(color: Colors.white)),
        content: const Text("Bu seferin tüm aşamaları otomatik olarak bitirilecek. Emin misin?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _quickCompleteMission(mission);
            },
            child: const Text("EVET, TAMAMLA", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedCard(Mission mission, bool isDark, String msg) {
    return Card(color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100], margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: ListTile(leading: Image.asset(mission.imagePath, width: 60, opacity: const AlwaysStoppedAnimation(0.2)), title: Text(mission.name, style: const TextStyle(color: Colors.grey)), subtitle: Text(msg, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)), trailing: const Icon(Icons.lock_outline, color: Colors.orangeAccent)));
  }

  Widget _buildStageTile(Mission mission, MissionStage stage, bool isDark) {
    int completed = _missionStages[mission.name] ?? 0;
    bool isDone = completed >= stage.stageNumber;
    bool isActive = !isDone && stage.stageNumber == completed + 1;
    Color color = isDone ? Colors.green : (isActive ? Colors.orangeAccent : Colors.grey);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50], borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text("${stage.stageNumber}. ${stage.name}${isDone ? " (Tamamlandı)" : ""}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        children: stage.requirements.map((req) => _buildRequirementRow(mission, stage, req, isActive, isDark)).toList(),
      ),
    );
  }

  Widget _buildRequirementRow(Mission mission, MissionStage stage, MissionRequirement req, bool isActive, bool isDark) {
    final key = "${mission.name}_${stage.name}_${req.id}";
    int current = _missionProgress[key] ?? 0;
    bool isDone = current >= req.requiredAmount;
    
    String iconPath = "assets/items/Item_Icon_Coins.webp";
    String displayName = req.displayName ?? req.id;
    
    if (req.type == RequirementType.item) {
      try {
        final item = ItemLibrary.resourceItems.firstWhere((i) => i.id == req.id);
        iconPath = "assets/items/${item.fileName}";
        displayName = item.nameTr;
      } catch (e) { iconPath = "assets/items/logo.webp"; }
    }

    String format(int v) => v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
      child: Row(
        children: [
          SizedBox(width: 30, height: 30, child: Image.asset(iconPath, errorBuilder: (c, e, s) => const Icon(Icons.help))),
          const SizedBox(width: 12),
          Expanded(child: Text(_capitalize(displayName), style: TextStyle(color: isActive ? (isDark ? Colors.white70 : Colors.black87) : Colors.grey, fontSize: 13))),
          Row(
            children: [
              _buildBtn(Icons.remove, isActive ? () => _changeRequirementCount(req, mission.name, stage.name, stage.stageNumber, -1) : null, isActive, isDark, onLong: isActive ? (d) => _startTimer(req, mission.name, stage.name, stage.stageNumber, -1) : null, onEnd: isActive ? (d) => _stopTimer() : null),
              SizedBox(width: req.type == RequirementType.coin ? 95 : 65, child: Center(child: req.type == RequirementType.coin ? Column(mainAxisSize: MainAxisSize.min, children: [Text(format(current), style: TextStyle(color: isDone ? Colors.greenAccent : (isActive ? Colors.white : Colors.grey), fontWeight: FontWeight.bold, fontSize: 10)), const Text("/", style: TextStyle(color: Colors.grey, fontSize: 8)), Text(format(req.requiredAmount), style: TextStyle(color: Colors.grey, fontSize: 9))]) : Text("$current/${req.requiredAmount}", style: TextStyle(color: isDone ? Colors.greenAccent : (isActive ? Colors.white : Colors.grey), fontWeight: FontWeight.bold, fontSize: 11)))),
              _buildBtn(Icons.add, isActive ? () => _changeRequirementCount(req, mission.name, stage.name, stage.stageNumber, 1) : null, isActive, isDark, onLong: isActive ? (d) => _startTimer(req, mission.name, stage.name, stage.stageNumber, 1) : null, onEnd: isActive ? (d) => _stopTimer() : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(IconData i, VoidCallback? t, bool a, bool d, {void Function(LongPressStartDetails)? onLong, void Function(LongPressEndDetails)? onEnd}) {
    return GestureDetector(onTap: t, onLongPressStart: onLong, onLongPressEnd: onEnd, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: a ? (d ? Colors.white10 : Colors.green.withOpacity(0.1)) : Colors.black26, borderRadius: BorderRadius.circular(5)), child: Icon(i, color: a ? (d ? Colors.white : Colors.green) : Colors.grey, size: 16)));
  }

  void _shareSingleMissionProgress(Mission mission) {
    final List<String> lines = ["ARC Raider Tracker - ${mission.name} İhtiyaç Listem (${widget.userName}):\n"];
    int completedStages = _missionStages[mission.name] ?? 0;
    MissionStage? activeStage;
    try { activeStage = mission.stages.firstWhere((s) => s.stageNumber == completedStages + 1); } catch (e) { activeStage = null; }
    if (activeStage != null) {
      List<String> neededReqs = [];
      for (var req in activeStage.requirements) {
        final key = "${mission.name}_${activeStage.name}_${req.id}";
        int current = _missionProgress[key] ?? 0;
        if (current < req.requiredAmount) {
          if (req.type == RequirementType.item) {
            final gameItem = ItemLibrary.resourceItems.firstWhere((item) => item.id == req.id, orElse: () => GameItem(id: "", nameTr: req.id, fileName: ""));
            neededReqs.add("  - ${gameItem.nameTr}: $current/${req.requiredAmount}");
          } else {
            String curStr = current.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
            String reqStr = req.requiredAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
            neededReqs.add("  - ${req.displayName ?? req.id}: $curStr/$reqStr");
          }
        }
      }
      if (neededReqs.isNotEmpty) { lines.add("* ${activeStage.stageNumber}. ${activeStage.name} için eksikler:"); lines.addAll(neededReqs); }
    } else { lines.add("Tebrikler! ${mission.name} projesini tamamen bitirdin! 🏆"); }
    Share.share(lines.join("\n"), subject: "${mission.name} İhtiyaç Listesi");
  }
}
