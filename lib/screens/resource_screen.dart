import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../data/item_repository.dart';
import '../models/game_models.dart';
import '../widgets/item_image.dart';

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
    _refreshItems();
  }

  void _refreshItems() {
    setState(() {
      _sortedItems = ItemRepository.resourceItems;
    });
  }

  String selectedCategory = "HEPSİ";
  final List<String> categories = ["HEPSİ", "RESOURCE", "MATERIAL", "TRINKET", "NATURE"];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _sortedItems.where((item) {
      final matchesSearch = item.displayName.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == "HEPSİ" || 
          item.category.toUpperCase().contains(selectedCategory) ||
          (selectedCategory == "RESOURCE" && item.category.toLowerCase().contains("material"));
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF030303),
      appBar: AppBar(
        title: Text("NESNE VERİ BANKASI", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Speranza veri tabanında ara...",
                    hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.purpleAccent, size: 18),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: categories.map((cat) {
                    bool isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 10),
                      child: ActionChip(
                        label: Text(cat, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white60)),
                        backgroundColor: isSelected ? Colors.purpleAccent : Colors.white.withOpacity(0.05),
                        side: BorderSide.none,
                        onPressed: () => setState(() => selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
      height: 86,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () => _showItemDetails(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(indexStr, style: GoogleFonts.inter(color: Colors.white10, fontSize: 10)),
                  const SizedBox(width: 12),
                  _buildItemImage(item),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.displayName.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(item.category.toUpperCase(), style: GoogleFonts.inter(color: Colors.purpleAccent.withOpacity(0.6), fontSize: 8, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.monitor_weight_outlined, color: Colors.white24, size: 10),
                            const SizedBox(width: 3),
                            Text("${item.weight.toStringAsFixed(1)} kg", style: GoogleFonts.inter(color: Colors.white38, fontSize: 8)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${item.sellPrice}", style: GoogleFonts.inter(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          const Icon(Icons.monetization_on_outlined, color: Colors.orangeAccent, size: 14),
                        ],
                      ),
                      Text("VAL", style: GoogleFonts.inter(color: Colors.white10, fontSize: 7, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(GameItem item) {
    return Container(
      width: 80, height: 80,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ItemImage(item: item, fit: BoxFit.cover),
      ),
    );
  }

  void _showItemDetails(GameItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildItemImage(item),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.displayName.toUpperCase(), style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.purpleAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(item.category.toUpperCase(), style: GoogleFonts.inter(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 10),
                                      Text("${item.sellPrice} COIN", style: GoogleFonts.inter(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 15),
                                      const Icon(Icons.monitor_weight_outlined, color: Colors.white24, size: 14),
                                      const SizedBox(width: 4),
                                      Text("${item.weight.toStringAsFixed(1)} KG", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text("AÇIKLAMA", style: GoogleFonts.inter(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text(item.description.isEmpty ? "Bu nesne için Speranza veri tabanında açıklama bulunamadı." : item.description,
                            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, height: 1.5)),
                        
                        if (item.craftingRecipe != null && item.craftingRecipe!.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          Text("ÜRETİM TARİFİ", style: GoogleFonts.inter(color: Colors.blueAccent, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          ...item.craftingRecipe!.map((req) => _buildRequirementRow(req)),
                        ],

                        if (item.recyclingYield != null && item.recyclingYield!.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          Text("GERİ DÖNÜŞÜM ÇIKTISI", style: GoogleFonts.inter(color: Colors.greenAccent, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          ...item.recyclingYield!.map((mat) => _buildRequirementRow(mat)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementRow(RequiredMaterial req) {
    final targetItem = ItemRepository.findById(req.itemId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
            child: ItemImage(item: targetItem, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Text("${req.quantity}x", style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(targetItem?.displayName ?? req.itemId, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}
