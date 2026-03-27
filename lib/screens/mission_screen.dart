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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.greenAccent, width: 2)),
        title: const Column(children: [Icon(Icons.verified, color: Colors.greenAccent, size: 40), SizedBox(height: 10), Text("OPERASYON TAMAMLANDI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
        content: Text("$missionName projesi başarıyla Speranza veri tabanına işlendi. Sefer hazırlıkları tamam.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [Center(child: TextButton(onPressed: () { _isPopupShowing = false; Navigator.pop(context); }, child: const Text("ANLAŞILDI", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold))))]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("OPERASYON DOSYALARI"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 20), onPressed: _showResetDialog)
        ],
      ),
      body: Column(
        children: [
          _broadcastHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: MissionData.allMissions.length,
              itemBuilder: (context, index) {
                final mission = MissionData.allMissions[index];
                bool isEnabled = true;
                if (index > 0) {
                  final prev = MissionData.allMissions[index - 1];
                  if ((_missionStages[prev.name] ?? 0) < prev.stages.length) isEnabled = false;
                }
                return _buildMissionHUDCard(mission, isDark, isEnabled);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _broadcastHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.greenAccent.withOpacity(0.1),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.satellite_alt, color: Colors.greenAccent, size: 12),
          SizedBox(width: 10),
          Text("AKTİF GÖREV TAKİBİ ÜNİTESİ - ÇEVRİMİÇİ", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildMissionHUDCard(Mission mission, bool isDark, bool isEnabled) {
    if (mission.isLocked) return _buildLockedHUDCard(mission, "VERİ ERİŞİMİ YOK");
    if (!isEnabled) return _buildLockedHUDCard(mission, "ÖNCEKİ VERİ SETİ EKSİK");
    
    int completed = _missionStages[mission.name] ?? 0;
    bool allDone = completed >= mission.stages.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: allDone ? Colors.greenAccent.withOpacity(0.02) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: allDone ? Colors.greenAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Image.asset(mission.imagePath, width: 30),
          ),
          title: Text(mission.name.toUpperCase(), style: TextStyle(color: allDone ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
          subtitle: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: mission.stages.length > 0 ? completed / mission.stages.length : 0,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(allDone ? Colors.greenAccent : Colors.orangeAccent),
                    minHeight: 2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text("$completed/${mission.stages.length}", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.share, size: 18, color: allDone ? Colors.greenAccent : Colors.white24),
            onPressed: () => _shareSingleMissionProgress(mission),
          ),
          children: mission.stages.map((stage) => _buildStageHUDTile(mission, stage, isDark)).toList(),
        ),
      ),
    );
  }

  Widget _buildLockedHUDCard(Mission mission, String msg) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.orangeAccent, size: 20),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mission.name.toUpperCase(), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                  Text(msg, style: const TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageHUDTile(Mission mission, MissionStage stage, bool isDark) {
    int completed = _missionStages[mission.name] ?? 0;
    bool isDone = completed >= stage.stageNumber;
    bool isActive = !isDone && stage.stageNumber == completed + 1;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.greenAccent.withOpacity(0.05) : (isActive ? Colors.orangeAccent.withOpacity(0.03) : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text("AŞAMA ${stage.stageNumber}: ${stage.name.toUpperCase()}", 
          style: TextStyle(color: isDone ? Colors.greenAccent : (isActive ? Colors.orangeAccent : Colors.white24), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
        children: stage.requirements.map((req) => _buildRequirementHUDRow(mission, stage, req, isActive, isDark)).toList(),
      ),
    );
  }

  Widget _buildRequirementHUDRow(Mission mission, MissionStage stage, MissionRequirement req, bool isActive, bool isDark) {
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
          Opacity(
            opacity: isActive ? 1.0 : 0.3,
            child: SizedBox(width: 25, height: 25, child: Image.asset(iconPath, errorBuilder: (c, e, s) => const Icon(Icons.help, size: 15))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(displayName.toUpperCase(), style: TextStyle(color: isDone ? Colors.greenAccent : (isActive ? Colors.white70 : Colors.white12), fontSize: 11, letterSpacing: 0.5))),
          Row(
            children: [
              _buildHUDBtn(Icons.remove, isActive ? () => _changeRequirementCount(req, mission.name, stage.name, stage.stageNumber, -1) : null, isActive, onLong: isActive ? (d) => _startTimer(req, mission.name, stage.name, stage.stageNumber, -1) : null, onEnd: isActive ? (d) => _stopTimer() : null),
              Container(
                width: req.type == RequirementType.coin ? 90 : 70,
                alignment: Alignment.center,
                child: Text("${format(current)}/${format(req.requiredAmount)}", 
                  style: TextStyle(color: isDone ? Colors.greenAccent : (isActive ? Colors.white : Colors.white10), fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              _buildHUDBtn(Icons.add, isActive ? () => _changeRequirementCount(req, mission.name, stage.name, stage.stageNumber, 1) : null, isActive, onLong: isActive ? (d) => _startTimer(req, mission.name, stage.name, stage.stageNumber, 1) : null, onEnd: isActive ? (d) => _stopTimer() : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHUDBtn(IconData i, VoidCallback? t, bool a, {void Function(LongPressStartDetails)? onLong, void Function(LongPressEndDetails)? onEnd}) {
    return GestureDetector(
      onTap: t, onLongPressStart: onLong, onLongPressEnd: onEnd, 
      child: Container(
        padding: const EdgeInsets.all(4), 
        decoration: BoxDecoration(color: a ? Colors.white.withOpacity(0.05) : Colors.transparent, borderRadius: BorderRadius.circular(4)), 
        child: Icon(i, color: a ? Colors.white70 : Colors.white10, size: 14)
      )
    );
  }

  void _showResetDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF1A1A1A), title: const Text("SIFIRLAMA ÜNİTESİ", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)), content: const Text("Bu seferin tüm verileri silinecek. Onaylıyor musun?", style: TextStyle(color: Colors.white70)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.grey))), TextButton(onPressed: () { Navigator.pop(context); _resetData(); }, child: const Text("VERİLERİ SİL", style: TextStyle(color: Colors.redAccent)))]));
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_stageKey);
    if (mounted) { setState(() { _missionProgress = {}; _missionStages = {}; }); _forceCheckAllStages(showPopup: false); }
  }

  void _shareSingleMissionProgress(Mission mission) {
    final List<String> lines = ["ARC RAIDER HUD - ${mission.name.toUpperCase()} RAPORU (${widget.userName}):\n"];
    int completedStages = _missionStages[mission.name] ?? 0;
    MissionStage? activeStage;
    try { activeStage = mission.stages.firstWhere((s) => s.stageNumber == completedStages + 1); } catch (e) { activeStage = null; }
    if (activeStage != null) {
      lines.add("* AKTİF AŞAMA: ${activeStage.stageNumber}. ${activeStage.name.toUpperCase()}");
      for (var req in activeStage.requirements) {
        final key = "${mission.name}_${activeStage.name}_${req.id}";
        int current = _missionProgress[key] ?? 0;
        if (current < req.requiredAmount) {
          final name = req.type == RequirementType.item ? ItemLibrary.resourceItems.firstWhere((i) => i.id == req.id).nameTr : (req.displayName ?? req.id);
          lines.add("  - $name: $current/${req.requiredAmount}");
        }
      }
    } else { lines.add("GÖREV TAMAMLANDI. SEFERE HAZIR."); }
    Share.share(lines.join("\n"), subject: "${mission.name} Durum Raporu");
  }
}
