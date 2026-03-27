import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'user_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  const SettingsScreen({super.key, required this.userName});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _toggleTheme(bool val) async {
    setState(() => _isDarkMode = val);
    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', val);
  }

  // --- KRİTİK VERİ TAŞIMA MOTORU ---
  Future<void> _updateUserName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.userName) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> users = prefs.getStringList('saved_raiders') ?? [];

    // Yeni isim zaten varsa engelle
    if (users.contains(newName)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bu isim zaten kullanılıyor!")),
        );
      }
      return;
    }

    // 1. ESKİ VERİLERİ ÇEK
    final oldProgress = prefs.getString('mission_progress_${widget.userName}');
    final oldStages = prefs.getString('mission_stages_${widget.userName}');
    final oldBenchStocks = prefs.getString('bench_stocks_${widget.userName}');
    final oldBenchLevels = prefs.getString('bench_levels_${widget.userName}');
    final oldInventory = prefs.getString('user_inventory_${widget.userName}');

    // 2. YENİ İSİME AKTAR
    if (oldProgress != null) await prefs.setString('mission_progress_$newName', oldProgress);
    if (oldStages != null) await prefs.setString('mission_stages_$newName', oldStages);
    if (oldBenchStocks != null) await prefs.setString('bench_stocks_$newName', oldBenchStocks);
    if (oldBenchLevels != null) await prefs.setString('bench_levels_$newName', oldBenchLevels);
    if (oldInventory != null) await prefs.setString('user_inventory_$newName', oldInventory);

    // 3. KULLANICI LİSTESİNİ GÜNCELLE
    int index = users.indexOf(widget.userName);
    if (index != -1) {
      users[index] = newName;
      await prefs.setStringList('saved_raiders', users);
      await prefs.setString('active_user', newName);

      // 4. ESKİ ÇÖPLERİ TEMİZLE
      await prefs.remove('mission_progress_${widget.userName}');
      await prefs.remove('mission_stages_${widget.userName}');
      await prefs.remove('bench_stocks_${widget.userName}');
      await prefs.remove('bench_levels_${widget.userName}');
      await prefs.remove('user_inventory_${widget.userName}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verileriniz yeni isminize başarıyla aktarıldı!")),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showAboutDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orangeAccent),
            const SizedBox(width: 10),
            Text("HAKKINDA", style: TextStyle(color: isDark ? Colors.white : Colors.black87, letterSpacing: 2)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ARC Raiders Tracker",
                  style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bu uygulama, Raiders topluluğunun Speranza'daki mücadelesini kolaylaştırmak, envanter ve projelerini daha verimli yönetebilmelerini sağlamak amacıyla geliştirilmiş gayriresmi bir yardımcı araçtır.",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 25),
                const Text(
                  "ÖZEL TEŞEKKÜRLER",
                  style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  "Uygulamanın gelişim sürecinde fikirleri, testleri ve destekleriyle yanımızda olan tüm Raider dostlarımıza sonsuz teşekkürler:",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text("• FriXioN", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15, height: 1.5)),
                Text("• Sosyoman", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15, height: 1.5)),
                Text("• DembeZumaTR", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15, height: 1.5)),
                Text("• Riddle", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15, height: 1.5)),
                const SizedBox(height: 20),
                const Text(
                  "Birlikte daha güçlüyüz!",
                  style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 25),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                const Text(
                  "YASAL UYARI / LEGAL NOTICE",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  "Bu uygulama resmi bir Embark Studios ürünü değildir. ARC Raiders markası, logoları ve tüm oyun içi varlıklar Embark Studios'un tescilli mülkiyetindedir. Bu proje tamamen hayran yapımıdır ve ticari amaç gütmez.\n\n"
                  "This is an unofficial fan app. ARC Raiders and all related assets are trademarks of Embark Studios. This project is not affiliated with or endorsed by Embark Studios.",
                  style: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 11),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Versiyon 1.0.1",
                    style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("KAPAT", style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("AYARLAR")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("RAIDER AYARLARI", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: _nameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  labelText: "Raider İsmi",
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateUserName,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black),
                child: const Text("İSMİ GÜNCELLE"),
              ),
              const Divider(height: 40),
              const Text("SİSTEM AYARLARI", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ListTile(
                tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                title: Text("Koyu Tema", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text(_isDarkMode ? "Gece Modu Aktif" : "Gündüz Modu Aktif", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: _toggleTheme,
                  activeColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: const Icon(Icons.info_outline, color: Colors.greenAccent),
                title: Text("Hakkında...", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                onTap: _showAboutDialog,
              ),
              const SizedBox(height: 40),
              Center(
                child: Opacity(
                  opacity: isDark ? 0.2 : 0.1,
                  child: Image.asset(
                    "assets/images/logo.webp",
                    width: 220,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Speranza Seni Bekliyor...",
                  style: TextStyle(color: isDark ? Colors.white10 : Colors.black12, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
