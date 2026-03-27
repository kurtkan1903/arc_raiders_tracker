import '../models/game_models.dart';

class MissionData {
  static final List<Mission> allMissions = [
    // --- SEFER 1 (EXPEDITION 1) ---
    Mission(
      name: "Sefer 1",
      imagePath: "assets/images/Expedition_Project_card.png",
      stages: [
        MissionStage(
          stageNumber: 1,
          name: "Temel",
          requirements: [
            MissionRequirement(id: "metal_parts", requiredAmount: 150, type: RequirementType.item),
            MissionRequirement(id: "rubber_parts", requiredAmount: 200, type: RequirementType.item),
            MissionRequirement(id: "arc_alloy", requiredAmount: 80, type: RequirementType.item),
            MissionRequirement(id: "steel_spring", requiredAmount: 15, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 2,
          name: "Çekirdek Sistemler",
          requirements: [
            MissionRequirement(id: "durable_cloth", requiredAmount: 35, type: RequirementType.item),
            MissionRequirement(id: "wires", requiredAmount: 30, type: RequirementType.item),
            MissionRequirement(id: "electrical_components", requiredAmount: 30, type: RequirementType.item),
            MissionRequirement(id: "cooling_fan", requiredAmount: 5, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 3,
          name: "İskelet",
          requirements: [
            MissionRequirement(id: "light_bulb", requiredAmount: 5, type: RequirementType.item),
            MissionRequirement(id: "battery", requiredAmount: 30, type: RequirementType.item),
            MissionRequirement(id: "sensors", requiredAmount: 20, type: RequirementType.item),
            MissionRequirement(id: "exodus_modules", requiredAmount: 1, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 4,
          name: "Donanım",
          requirements: [
            MissionRequirement(id: "humidifier", requiredAmount: 5, type: RequirementType.item),
            MissionRequirement(id: "advanced_electrical_components", requiredAmount: 5, type: RequirementType.item),
            MissionRequirement(id: "magnetic_accelerator", requiredAmount: 3, type: RequirementType.item),
            MissionRequirement(id: "leaper_pulse_unit", requiredAmount: 3, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 5,
          name: "Yükleme Aşaması",
          requirements: [
            MissionRequirement(id: "combat_items", displayName: "Savaş Eşyaları", requiredAmount: 250000, type: RequirementType.coin, description: "Mühimmat, Bombalar, Tuzaklar, Silahlar, Silah Modları"),
            MissionRequirement(id: "survival_items", displayName: "Hayatta Kalma Eşyaları", requiredAmount: 100000, type: RequirementType.coin, description: "Kalkanlar, Gadget'lar, Yardımcı Araçlar, Geliştirmeler, Yenileyiciler"),
            MissionRequirement(id: "provisions", displayName: "Erzaklar", requiredAmount: 180000, type: RequirementType.coin, description: "Doğa, Çeşitli Eşyalar, Yadigarlar, Eski Dünya, Anahtarlar"),
            MissionRequirement(id: "materials", displayName: "Malzemeler", requiredAmount: 300000, type: RequirementType.coin, description: "Hammadde ve Üretim Kaynakları"),
          ],
        ),
        MissionStage(
          stageNumber: 6,
          name: "Unload Inventory",
          requirements: [
            MissionRequirement(id: "inventory_value", displayName: "Envanter Değeri", requiredAmount: 5000000, type: RequirementType.coin, description: "Tüm envanterdeki eşyaların toplam değeri"),
          ],
        ),
      ],
    ),

    // --- SEFER 2 (EXPEDITION 2) ---
    Mission(
      name: "Sefer 2",
      imagePath: "assets/images/Expedition_Project_card.png",
      stages: [
        MissionStage(
          stageNumber: 1,
          name: "Temel",
          requirements: [
            MissionRequirement(id: "metal_parts", requiredAmount: 150, type: RequirementType.item),
            MissionRequirement(id: "plastic_parts", requiredAmount: 200, type: RequirementType.item),
            MissionRequirement(id: "arc_alloy", requiredAmount: 80, type: RequirementType.item),
            MissionRequirement(id: "steel_spring", requiredAmount: 15, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 2,
          name: "Çekirdek Sistemler",
          requirements: [
            MissionRequirement(id: "durable_cloth", requiredAmount: 35, type: RequirementType.item),
            MissionRequirement(id: "wires", requiredAmount: 25, type: RequirementType.item),
            MissionRequirement(id: "electrical_components", requiredAmount: 20, type: RequirementType.item),
            MissionRequirement(id: "cooling_coil", requiredAmount: 4, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 3,
          name: "İskelet",
          requirements: [
            MissionRequirement(id: "light_bulb", requiredAmount: 4, type: RequirementType.item),
            MissionRequirement(id: "battery", requiredAmount: 30, type: RequirementType.item),
            MissionRequirement(id: "shredder_gyro", requiredAmount: 10, type: RequirementType.item),
            MissionRequirement(id: "exodus_modules", requiredAmount: 1, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 4,
          name: "Donanım",
          requirements: [
            MissionRequirement(id: "frequency_modulation_box", requiredAmount: 5, type: RequirementType.item),
            MissionRequirement(id: "advanced_electrical_components", requiredAmount: 5, type: RequirementType.item),
            MissionRequirement(id: "ion_sputter", requiredAmount: 3, type: RequirementType.item),
            MissionRequirement(id: "leaper_pulse_unit", requiredAmount: 3, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 5,
          name: "Yükleme Aşaması",
          requirements: [
            MissionRequirement(id: "combat_items", displayName: "Savaş Eşyaları", requiredAmount: 250000, type: RequirementType.coin, description: "Mühimmat, Bombalar, Tuzaklar, Silahlar, Silah Modları"),
            MissionRequirement(id: "survival_items", displayName: "Hayatta Kalma Eşyaları", requiredAmount: 100000, type: RequirementType.coin, description: "Kalkanlar, Gadget'lar, Yardımcı Araçlar, Geliştirmeler, Yenileyiciler"),
            MissionRequirement(id: "provisions", displayName: "Erzaklar", requiredAmount: 180000, type: RequirementType.coin, description: "Doğa, Çeşitli Eşyalar, Yadigarlar, Eski Dünya, Anahtarlar"),
            MissionRequirement(id: "materials", displayName: "Malzemeler", requiredAmount: 300000, type: RequirementType.coin, description: "Hammadde ve Üretim Kaynakları"),
          ],
        ),
        MissionStage(
          stageNumber: 6,
          name: "Unload Inventory",
          requirements: [
            MissionRequirement(id: "inventory_value", displayName: "Envanter Değeri", requiredAmount: 3000000, type: RequirementType.coin, description: "Tüm envanterdeki eşyaların toplam değeri"),
          ],
        ),
      ],
    ),

    // --- SEFER 3 (EXPEDITION 3) ---
    Mission(
      name: "Sefer 3",
      imagePath: "assets/images/Expedition_Project_card.png",
      isLocked: false,
      stages: [
        MissionStage(
          stageNumber: 1,
          name: "Temel",
          requirements: [
            MissionRequirement(id: "metal_parts", requiredAmount: 150, type: RequirementType.item),
            MissionRequirement(id: "chemicals", requiredAmount: 100, type: RequirementType.item),
            MissionRequirement(id: "arc_alloy", requiredAmount: 80, type: RequirementType.item),
            MissionRequirement(id: "steel_spring", requiredAmount: 15, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 2,
          name: "Çekirdek Sistemler",
          requirements: [
            MissionRequirement(id: "durable_cloth", requiredAmount: 30, type: RequirementType.item),
            MissionRequirement(id: "wires", requiredAmount: 25, type: RequirementType.item),
            MissionRequirement(id: "electrical_components", requiredAmount: 20, type: RequirementType.item),
            MissionRequirement(id: "industrial_charger", requiredAmount: 3, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 3,
          name: "İskelet",
          requirements: [
            MissionRequirement(id: "coffee_pot", requiredAmount: 1, type: RequirementType.item),
            MissionRequirement(id: "battery", requiredAmount: 25, type: RequirementType.item),
            MissionRequirement(id: "firefly_burner", requiredAmount: 5, type: RequirementType.item),
            MissionRequirement(id: "exodus_modules", requiredAmount: 1, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 4,
          name: "Donanım",
          requirements: [
            MissionRequirement(id: "broken_guidance_system", requiredAmount: 1, type: RequirementType.item),
            MissionRequirement(id: "advanced_electrical_components", requiredAmount: 5, type: RequirementType.item),
            MissionRequirement(id: "breathtaking_snow_globe", requiredAmount: 3, type: RequirementType.item),
            MissionRequirement(id: "bombardier_cell", requiredAmount: 2, type: RequirementType.item),
          ],
        ),
        MissionStage(
          stageNumber: 5,
          name: "Yükleme Aşaması",
          requirements: [
            MissionRequirement(id: "combat_items", displayName: "Savaş Eşyaları", requiredAmount: 200000, type: RequirementType.coin, description: "Mühimmat, Bombalar, Tuzaklar, Silahlar, Silah Modları"),
            MissionRequirement(id: "survival_items", displayName: "Hayatta Kalma Eşyaları", requiredAmount: 100000, type: RequirementType.coin, description: "Kalkanlar, Gadget'lar, Yardımcı Araçlar, Geliştirmeler, Yenileyiciler"),
            MissionRequirement(id: "provisions", displayName: "Erzaklar", requiredAmount: 150000, type: RequirementType.coin, description: "Doğa, Çeşitli Eşyalar, Yadigarlar, Eski Dünya, Anahtarlar"),
            MissionRequirement(id: "materials", displayName: "Malzemeler", requiredAmount: 300000, type: RequirementType.coin, description: "Hammadde ve Üretim Kaynakları"),
          ],
        ),
        MissionStage(
          stageNumber: 6,
          name: "Unload Inventory",
          requirements: [
            MissionRequirement(id: "inventory_value", displayName: "Envanter Değeri", requiredAmount: 3000000, type: RequirementType.coin, description: "Tüm envanterdeki eşyaların toplam değeri"),
          ],
        ),
      ],
    ),

    // --- SEFER 4 (LOCKED) ---
    Mission(
      name: "Sefer 4",
      imagePath: "assets/images/Expedition_Project_card.png",
      isLocked: true,
      stages: [],
    ),
  ];
}
