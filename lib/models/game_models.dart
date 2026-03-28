import 'dart:convert';

// --- ORTAK MODELLER ---
enum ItemRarity { common, uncommon, rare, epic, legendary }

class GameItem {
  final String id;
  final String nameTr;
  final String fileName;
  final String category;
  final ItemRarity rarity;
  final int value;
  final String description;
  final String? location;
  final List<RequiredMaterial>? craftingRecipe;
  final List<RequiredMaterial>? recyclingYield;

  GameItem({
    required this.id,
    required this.nameTr,
    required this.fileName,
    this.category = "Genel",
    this.rarity = ItemRarity.common,
    this.value = 0,
    this.description = "",
    this.location,
    this.craftingRecipe,
    this.recyclingYield,
  });
}

// --- TEZGAH MODELLERİ ---
class RequiredMaterial {
  final String itemId; 
  final int quantity;

  RequiredMaterial({required this.itemId, required this.quantity});
}

class BenchLevel {
  final int level;
  final List<RequiredMaterial> materials;

  BenchLevel({required this.level, required this.materials});
}

class Bench {
  final String id; // Görseller ve veri takibi için sabit ID
  final String name; // Ekranda görünecek isim (Türkçe)
  final List<BenchLevel> levels;

  Bench({required this.id, required this.name, required this.levels});
}

// --- GÖREV MODELLERİ ---
enum RequirementType { item, coin }

class MissionRequirement {
  final String id; 
  final int requiredAmount;
  final RequirementType type;
  final String? displayName; 
  final String? description; 

  MissionRequirement({
    required this.id,
    required this.requiredAmount,
    required this.type,
    this.displayName,
    this.description,
  });
}

class MissionStage {
  final String name;
  final int stageNumber;
  final List<MissionRequirement> requirements;

  MissionStage({required this.name, required this.stageNumber, required this.requirements});
}

class Mission {
  final String name;
  final String imagePath;
  final bool isLocked;
  final List<MissionStage> stages;

  Mission({
    required this.name,
    required this.imagePath,
    this.isLocked = false,
    required this.stages,
  });
}

// --- KULLANICI MODELİ ---
class UserInventory {
  final String userName;
  Map<String, int> stocks;

  UserInventory({
    required this.userName,
    required this.stocks,
  });

  String toJson() => json.encode({
    'userName': userName,
    'stocks': stocks,
  });

  factory UserInventory.fromJson(String source) {
    final data = json.decode(source);
    return UserInventory(
      userName: data['userName'],
      stocks: Map<String, int>.from(data['stocks']),
    );
  }
}
