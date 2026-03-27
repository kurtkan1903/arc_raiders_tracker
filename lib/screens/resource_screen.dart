import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/item_library.dart';
import '../models/game_models.dart';

class ResourceScreen extends StatefulWidget {
  final String userName;
  const ResourceScreen({super.key, required this.userName});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  Map<String, int> resourceStocks = {};
  String searchQuery = "";
  List<GameItem> _sortedResourceItems = [];

  // Kullanıcıya özel depolama anahtarı
  String get _storageKey => 'resource_inventory_${widget.userName}';

  @override
  void initState() {
    super.initState();
    _loadResourceStocks();
    _sortResourceItems();
  }

  void _sortResourceItems() {
    const turkishAlphabet = "abcçdefgğhıijklmnoöprsştuüvyz";
    _sortedResourceItems = List.from(ItemLibrary.resourceItems);

    _sortedResourceItems.sort((a, b) {
      String nameA = a.nameTr.toLowerCase();
      String nameB = b.nameTr.toLowerCase();
      int len = nameA.length < nameB.length ? nameA.length : nameB.length;
      for (int i = 0; i < len; i++) {
        int indexA = turkishAlphabet.indexOf(nameA[i]);
        int indexB = turkishAlphabet.indexOf(nameB[i]);
        if (indexA != -1 && indexB != -1) {
          if (indexA != indexB) {
            return indexA.compareTo(indexB);
          }
        } else {
          final int compare = nameA[i].compareTo(nameB[i]);
          if (compare != 0) {
            return compare;
          }
        }
      }
      return nameA.length.compareTo(nameB.length);
    });
  }

  Future<void> _loadResourceStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_storageKey);
    if (savedData != null && mounted) {
      setState(() {
        resourceStocks = Map<String, int>.from(json.decode(savedData));
      });
    }
  }

  Future<void> _saveResourceStocks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(resourceStocks));
  }

  void _changeStock(String id, int delta) {
    setState(() {
      int current = resourceStocks[id] ?? 0;
      resourceStocks[id] = (current + delta).clamp(0, 9999);
    });
    _saveResourceStocks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = _sortedResourceItems.where((item) {
      return item.nameTr.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("EŞYA ENVANTERİ"),
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "İsme göre ara...",
                prefixIcon: const Icon(Icons.search, color: Colors.orangeAccent),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredResources.length,
        itemBuilder: (context, index) {
          final item = filteredResources[index];
          final count = resourceStocks[item.id] ?? 0;
          return _buildResourceItem(item, count);
        },
      ),
    );
  }

  Widget _buildResourceItem(GameItem item, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: count > 0 ? Colors.orangeAccent.withOpacity(0.5) : Colors.white10),
      ),
      child: ListTile(
        leading: Image.asset("assets/items/${item.fileName}", width: 45, height: 45, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_rounded, color: Colors.orangeAccent)),
        title: Text(item.nameTr, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn(Icons.remove, () => _changeStock(item.id, -1)),
            SizedBox(width: 40, child: Center(child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 16)))),
            _btn(Icons.add, () => _changeStock(item.id, 1)),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
        child: Icon(icon, color: Colors.orangeAccent, size: 18),
      ),
    );
  }
}
