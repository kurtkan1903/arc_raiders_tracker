import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
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
      backgroundColor: const Color(0xFF030303),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Colors.purpleAccent.withOpacity(0.05), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
                  ),
                  child: const Icon(Icons.security_outlined, size: 50, color: Colors.purpleAccent),
                ),
                const SizedBox(height: 30),
                Text("KİMLİK DOĞRULAMA",
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 5)),
                const SizedBox(height: 8),
                Text("SİSTEME GİRİŞ YAPMAK İÇİN BİR KARAKTER SEÇİN", 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 50),

                _speranzaNewsButton(),

                const SizedBox(height: 30),
                _sectionHeader("KAYITLI RADIERS"),
                const SizedBox(height: 20),

                Expanded(
                  child: _users.isEmpty
                      ? Center(child: Text("YENİ BİR RAIDERA İHTİYAÇ VAR", style: GoogleFonts.inter(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.bold)))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) => _userCard(_users[index]),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      _actionBtn("YENİ KARAKTER TESPİT ET", Icons.add_circle_outline, Colors.purpleAccent, _showAddUserDialog),
                      const SizedBox(height: 20),
                      Text("SPERANZA SENİ BEKLİYOR, RAIDER.", style: GoogleFonts.inter(color: Colors.white12, fontSize: 9, letterSpacing: 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.inter(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 3)),
        const SizedBox(width: 15),
        const Expanded(child: Divider(color: Colors.white10, height: 1)),
      ],
    );
  }

  Widget _actionBtn(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _speranzaNewsButton() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PatchNotesScreen()));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.radar, color: Colors.blueAccent, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SPERANZA MERKEZİ", 
                        style: GoogleFonts.inter(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text("Bölgelerden gelen son raporlar", 
                        style: GoogleFonts.inter(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white10, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userCard(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.person_outline, color: Colors.purpleAccent, size: 20),
            ),
            title: Text(name.toUpperCase(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white10, size: 20),
              onPressed: () => _showDeleteConfirmationDialog(name),
            ),
            onTap: () => _selectUserAndNavigate(name),
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
          title: Text("YENİ RAIDERA KAYDI", style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
          content: TextField(
            controller: controller,
            maxLength: 20,
            autofocus: true,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: "RAIDER İSMİ...",
              hintStyle: GoogleFonts.inter(color: Colors.white10, fontSize: 10),
              counterStyle: GoogleFonts.inter(color: Colors.white10),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent, width: 2)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("İPTAL", style: GoogleFonts.inter(color: Colors.white24, fontSize: 10))),
            TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    _addNewUser(controller.text);
                    Navigator.pop(context);
                  }
                },
                child: Text("DOSYALA", style: GoogleFonts.inter(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF121212),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
          title: Text("KAYIT İMHASI", style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
          content: Text(
            "'$name' VERİLERİ KALICI OLARAK İMHA EDİLECEK. ONAYLIYOR MUSUN?",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İPTAL", style: GoogleFonts.inter(color: Colors.white24, fontSize: 10)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteUser(name);
              },
              child: Text("İMHA ET", style: GoogleFonts.inter(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
