import 'package:flutter/material.dart';
import '../data/item_library.dart';
import '../models/game_models.dart';

class ResourceScreen extends StatefulWidget {
  final String userName;
  const ResourceScreen({super.key, required this.userName});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  String searchQuery = "";
  List<GameItem> _sortedItems = [];

  @override
  void initState() {
    super.initState();
    _sortItems();
  }

  void _sortItems() {
    const turkishAlphabet = "abcçdefgğhıijklmnoöprsştuüvyz";
    _sortedItems = List.from(ItemLibrary.allItems);

    _sortedItems.sort((a, b) {
      String nameA = a.nameTr.toLowerCase();
      String nameB = b.nameTr.toLowerCase();
      int len = nameA.length < nameB.length ? nameA.length : nameB.length;
      for (int i = 0; i < len; i++) {
        int indexA = turkishAlphabet.indexOf(nameA[i]);
        int indexB = turkishAlphabet.indexOf(nameB[i]);
        if (indexA != -1 && indexB != -1) {
          if (indexA != indexB) return indexA.compareTo(indexB);
        } else {
          final int compare = nameA[i].compareTo(nameB[i]);
          if (compare != 0) return compare;
        }
      }
      return nameA.length.compareTo(nameB.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _sortedItems.where((item) {
      return item.nameTr.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("SPERANZA VERİ BANKASI"),
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Veri tabanında ara...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent, size: 20),
                filled: true,
                fillColor: const Color(0xFF161616),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.purpleAccent.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.purpleAccent.withOpacity(0.5)),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          final indexStr = (index + 1).toString().padLeft(3, '0');
          return _buildWikiHUDItem(item, indexStr);
        },
      ),
    );
  }

  Widget _buildWikiHUDItem(GameItem item, String indexStr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: () => _showItemDetails(item),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(indexStr, style: const TextStyle(color: Colors.white12, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(width: 12),
            Container(
              width: 40, height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
              child: Image.asset(
                item.fileName.startsWith("Bp_") ? "assets/blueprints/${item.fileName}" : "assets/items/${item.fileName}",
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2_outlined, color: Colors.purpleAccent, size: 18),
              ),
            ),
          ],
        ),
        title: Text(item.nameTr.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
        subtitle: Text(item.category, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${item.value}", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
            const Icon(Icons.monetization_on_outlined, color: Colors.white24, size: 12),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 12),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(GameItem item) {
    String format(int v) => v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                    child: Image.asset(
                      item.fileName.startsWith("Bp_") ? "assets/blueprints/${item.fileName}" : "assets/items/${item.fileName}",
                      errorBuilder: (c, e, s) => const Icon(Icons.help_outline, color: Colors.purpleAccent, size: 30),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nameTr.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(5)),
                              child: Text(item.category.toUpperCase(), style: const TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.monetization_on_outlined, color: Colors.white24, size: 14),
                            const SizedBox(width: 4),
                            Text("${format(item.value)} COIN", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text("TEKNİK ANALİZ", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 10),
              Text(item.description, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
              if (item.location != null) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.redAccent, size: 14),
                    const SizedBox(width: 5),
                    Text("KONUM: ${item.location}", style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),
              
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildRecipeSection("ÜRETİM ŞEMASI (CRAFTING)", item.craftingRecipe, Colors.orangeAccent),
                    const SizedBox(height: 30),
                    _buildRecipeSection("GERİ DÖNÜŞÜM VERİSİ (RECYCLE)", item.recyclingYield, Colors.greenAccent),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeSection(String title, List<RequiredMaterial>? materials, Color color) {
    if (materials == null || materials.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 10),
          const Text("VERİ TABANINDA KAYIT BULUNAMADI", style: TextStyle(color: Colors.white10, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 15),
        ...materials.map((mat) {
          String matName = mat.itemId.replaceAll("_", " ").toUpperCase();
          try {
            final found = ItemLibrary.allItems.firstWhere((i) => i.id == mat.itemId);
            matName = found.nameTr.toUpperCase();
          } catch (e) {}

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.api_outlined, color: color.withOpacity(0.5), size: 16),
                const SizedBox(width: 10),
                Expanded(child: Text(matName, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
                Text("x${mat.quantity}", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
