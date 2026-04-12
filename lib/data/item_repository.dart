import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../models/game_models.dart';

class ItemRepository {
  static List<GameItem>? _allItems;
  static List<GameItem>? _resourceItems;
  static List<GameItem>? _blueprintItems;

  static ItemRarity _parseRarity(String? rarity) {
    switch (rarity?.toLowerCase()) {
      case 'uncommon': return ItemRarity.uncommon;
      case 'rare': return ItemRarity.rare;
      case 'epic': return ItemRarity.epic;
      case 'legendary': return ItemRarity.legendary;
      default: return ItemRarity.common;
    }
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static String _generateId(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r"['\(\)\-\. ]"), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  // Wiki URL Oluşturucu (MD5 tabanlı doğrudan URL)
  static String _getWikiImageUrl(String fileName) {
    // MediaWiki hash pattern: /w/images/a/ab/Filename.png
    // ab = md5(Filename.png).substring(0,2)
    // a = md5(Filename.png).substring(0,1)
    
    final normalized = fileName.replaceAll(' ', '_');
    final bytes = utf8.encode(normalized);
    final digest = md5.convert(bytes).toString();
    final a = digest.substring(0, 1);
    final ab = digest.substring(0, 2);
    
    return 'https://arcraiders.wiki/w/images/$a/$ab/$normalized';
  }

  static Future<void> initialize() async {
    if (_allItems != null) return;

    // Blueprint konfigürasyonunu yükle
    final String bpConfigStr = await rootBundle.loadString('assets/data/blueprints_config.json');
    final List<dynamic> bpConfigData = json.decode(bpConfigStr);
    final Map<String, dynamic> bpMap = {for (var bp in bpConfigData) bp['originalName'].toString().toLowerCase(): bp};
    final Map<String, dynamic> bpIdMap = {for (var bp in bpConfigData) bp['id'].toString().toLowerCase(): bp};

    final String jsonStr = await rootBundle.loadString('assets/data/items_database.json');
    final List<dynamic> data = json.decode(jsonStr);

    final Set<String> processedBpNames = {};
    _allItems = data.map((item) {
      final infobox = (item['infobox'] is Map) ? (item['infobox'] as Map<String, dynamic>) : <String, dynamic>{};
      final imageUrls = (item['image_urls'] is Map) ? (item['image_urls'] as Map<String, dynamic>) : <String, dynamic>{};
      final String name = item['name'] as String? ?? '';
      
      // Blueprint kontrolü
      final String nameKey = name.toLowerCase();
      final String idKey = _generateId(name).toLowerCase();
      final dynamic bpData = bpMap[nameKey] ?? bpIdMap[idKey];
      final bool isBlueprint = bpData != null;

      // Crafting & Recycling Verisi Ayıklama
      List<RequiredMaterial>? craftingRecipe;
      if (item['crafting'] is List && (item['crafting'] as List).isNotEmpty) {
        final recipeData = (item['crafting'] as List).first['recipe'];
        if (recipeData is List) {
          craftingRecipe = recipeData.map((r) => RequiredMaterial(
            itemId: _generateId(r['item'] as String? ?? ''),
            quantity: _parseInt(r['quantity'], 1),
          )).toList();
        }
      }

      List<RequiredMaterial>? recyclingYield;
      final recyclingData = item['recycling'];
      if (recyclingData is Map && recyclingData['recycling'] is List && (recyclingData['recycling'] as List).isNotEmpty) {
        final materials = (recyclingData['recycling'] as List).first['materials'];
        if (materials is List) {
          recyclingYield = materials.map((m) => RequiredMaterial(
            itemId: _generateId(m['item'] as String? ?? ''),
            quantity: _parseInt(m['quantity'], 1),
          )).toList();
        }
      }

      String? finalImageUrl;
      if (isBlueprint && bpData != null && bpData['fileName'] != null) {
        final String fileName = bpData['fileName'];
        final String fileNameWithExt = fileName.contains('.') ? fileName : "$fileName.png";
        finalImageUrl = _getWikiImageUrl(fileNameWithExt);
      } else {
        finalImageUrl = (imageUrls['thumb'] as String?) ?? 
                 (infobox['image'] != null ? _getWikiImageUrl(infobox['image'] as String) : null);
      }

      final newItem = GameItem(
        id: _generateId(name),
        nameTr: isBlueprint ? bpData['nameTr'] : "", 
        nameEn: name,
        imageUrl: finalImageUrl,
        category: infobox['type'] as String? ?? 'Genel',
        rarity: _parseRarity(infobox['rarity'] as String?),
        description: infobox['quote'] as String? ?? '',
        location: infobox['location'] as String?,
        stackSize: _parseInt(infobox['stacksize'], 1),
        weight: _parseDouble(infobox['weight'], 0.0),
        sellPrice: _parseInt(infobox['sellprice'], 0),
        craftingRecipe: craftingRecipe,
        recyclingYield: recyclingYield,
      );

      if (isBlueprint) processedBpNames.add(name.toLowerCase());
      return newItem;
    }).toList(); 

    // 2. Eksik Blueprint'leri Manuel Ekle (Database'de olmayan ama config'de olanlar: Yeşil Işık Çubuğu vb.)
    for (var bpName in bpMap.keys) {
      if (!processedBpNames.contains(bpName.toLowerCase())) {
        final bpData = bpMap[bpName]!;
        final String originalName = bpData['originalName'] ?? bpName;
        final String fileName = bpData['fileName'] ?? originalName;
        final String fileNameWithExt = fileName.contains('.') ? fileName : "$fileName.png";
        
        final String generatedUrl = _getWikiImageUrl(fileNameWithExt);
        // ignore: avoid_print
        print("DEBUG: Injecting missing item: ${bpData['originalName'] ?? bpName} -> $generatedUrl");

        _allItems?.add(GameItem(
          id: _generateId(originalName),
          nameTr: bpData['nameTr'] ?? "",
          nameEn: originalName,
          imageUrl: generatedUrl,
          category: originalName.contains('Light Stick') ? 'Consumables' : 'Blueprint',
          rarity: ItemRarity.uncommon,
          description: 'Blueprint module for ${bpData['nameTr']}',
          stackSize: 1,
        ));
      }
    }

    // Blueprint'leri ve resource'ları ayır
    _blueprintItems = _allItems?.where((item) {
      final String idKey = item.id.toLowerCase();
      final String nameKey = item.nameEn.toLowerCase();
      return bpIdMap.containsKey(idKey) || bpMap.containsKey(nameKey);
    }).toList();

    _resourceItems = _allItems?.toList();

    // Sıralama fonksiyonu (Türkçe alfabeye duyarlı)
    int turkishSort(GameItem a, GameItem b) {
      const turkishAlphabet = "abcçdefgğhıijklmnoöprsştuüvyz";
      String nameA = a.displayName.toLowerCase();
      String nameB = b.displayName.toLowerCase();
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
    }

    _blueprintItems?.sort(turkishSort);
    _resourceItems?.sort(turkishSort);
  }

  static List<GameItem> get allItems => _allItems ?? [];
  static List<GameItem> get resourceItems => _resourceItems ?? [];
  static List<GameItem> get blueprintItems => _blueprintItems ?? [];

  static GameItem? findByName(String name) {
    final id = _generateId(name);
    try {
      return _allItems?.firstWhere((item) => item.id == id || item.nameEn == name);
    } catch (_) {
      return null;
    }
  }

  static GameItem? findById(String id) {
    try {
      return _allItems?.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
