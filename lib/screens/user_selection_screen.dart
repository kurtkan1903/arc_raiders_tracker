import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'patch_notes_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<String> _users = [];
  final String _storageKey = 'saved_raiders';
  final String _activeUserKey = 'active_user';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _users = prefs.getStringList(_storageKey) ?? [];
      });
    }
  }

  Future<void> _addNewUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _users.add(name);
      prefs.setStringList(_storageKey, _users);
    });
  }

  Future<void> _deleteUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _users.remove(name);
      prefs.setStringList(_storageKey, _users);
    });
    final activeUser = prefs.getString(_activeUserKey);
    if (activeUser == name) {
      await prefs.remove(_activeUserKey);
    }
  }

  Future<void> _selectUserAndNavigate(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, name);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(userName: name)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.security, size: 70, color: Colors.orangeAccent),
              const SizedBox(height: 20),
              const Text("KİMLİK DOĞRULAMA",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4)),
              const SizedBox(height: 10),
              const Text("Devam etmek için bir karakter seçin", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 40),

              _speranzaNewsButton(),

              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("KAYITLI RAIDERS", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const Expanded(child: Divider(indent: 10, color: Colors.white10)),
                ],
              ),
              const SizedBox(height: 15),

              Expanded(
                child: _users.isEmpty
                    ? const Center(child: Text("Henüz karakter oluşturulmadı", style: TextStyle(color: Colors.white54, fontSize: 13)))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) => _userCard(_users[index]),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAddUserDialog,
                      icon: const Icon(Icons.add_reaction_outlined),
                      label: const Text("YENİ KARAKTER OLUŞTUR"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Speranza seni bekliyor, Raider.", style: TextStyle(color: Colors.white10, fontSize: 10, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _speranzaNewsButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PatchNotesScreen()));
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.15), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.radar, color: Colors.blueAccent.withOpacity(0.5), size: 40),
                const Icon(Icons.rss_feed, color: Colors.blueAccent, size: 20),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SPERANZA'DA NELER OLUYOR?", 
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text("Bölge raporlarını ve güncellemeleri anlık takip et.", 
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _userCard(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 20, right: 10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Colors.orangeAccent, size: 20),
        ),
        title: Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 20),
          tooltip: "Karakteri Sil",
          onPressed: () => _showDeleteConfirmationDialog(name),
        ),
        onTap: () => _selectUserAndNavigate(name),
      ),
    );
  }

  void _showAddUserDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("YENİ RAIDER KAYDI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLength: 20,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Raider İsmi...",
            counterStyle: TextStyle(color: Colors.grey),
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addNewUser(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("KAYDET", style: TextStyle(color: Colors.orangeAccent))),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("KAYIT SİLME", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          "'$name' verileri kalıcı olarak imha edilecek. Onaylıyor musun?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İPTAL", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(name);
            },
            child: const Text("SİL", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
