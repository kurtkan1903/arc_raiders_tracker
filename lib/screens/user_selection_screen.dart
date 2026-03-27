import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<String> _users = [];
  final String _storageKey = 'saved_raiders';
  final String _activeUserKey = 'active_user'; // Aktif kullanıcıyı saklamak için anahtar

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
    // Eğer silinen kullanıcı aktif kullanıcı ise, aktif kullanıcı bilgisini de temizle
    final activeUser = prefs.getString(_activeUserKey);
    if (activeUser == name) {
      await prefs.remove(_activeUserKey);
    }
  }

  // Aktif kullanıcıyı ayarlayan ve Dashboard'a yönlendiren metot
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
              const SizedBox(height: 60),
              const Icon(Icons.security, size: 80, color: Colors.orangeAccent),
              const SizedBox(height: 20),
              const Text("KİMLİK DOĞRULAMA",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)),
              const SizedBox(height: 10),
              const Text("Devam etmek için bir karakter seçin", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              Expanded(
                child: _users.isEmpty
                    ? const Center(child: Text("Henüz karakter oluşturulmadı", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) => _userCard(_users[index]),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add_reaction_outlined),
                  label: const Text("YENİ KARAKTER OLUŞTUR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userCard(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 20, right: 10),
        leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
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
        title: const Text("Karakter Oluştur", style: TextStyle(color: Colors.white)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL")),
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
        title: const Text("Karakteri Sil", style: TextStyle(color: Colors.white)),
        content: Text(
          "'$name' isimli karakteri kalıcı olarak silmek istediğinize emin misiniz?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İPTAL"),
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
