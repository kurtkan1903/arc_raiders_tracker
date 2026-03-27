import '../models/game_models.dart';

class BenchData {
  static final List<Bench> allBenches = [
    // 1. HURDACI (Scrappy)
    Bench(
      id: "scrappy",
      name: "Hurdacı",
      levels: [
        BenchLevel(level: 2, materials: [RequiredMaterial(itemId: "dog_collar", quantity: 1)]),
        BenchLevel(level: 3, materials: [RequiredMaterial(itemId: "lemon", quantity: 3), RequiredMaterial(itemId: "apricot", quantity: 3)]),
        BenchLevel(level: 4, materials: [
          RequiredMaterial(itemId: "prickly_pear", quantity: 6),
          RequiredMaterial(itemId: "olives", quantity: 6),
          RequiredMaterial(itemId: "cat_bed", quantity: 1)
        ]),
        BenchLevel(level: 5, materials: [
          RequiredMaterial(itemId: "mushroom", quantity: 12),
          RequiredMaterial(itemId: "apricot", quantity: 12),
          RequiredMaterial(itemId: "very_comfortable_pillow", quantity: 3)
        ]),
      ],
    ),

    // 2. SİLAHÇI (Gunsmith)
    Bench(
      id: "gunsmith",
      name: "Silahçı",
      levels: [
        BenchLevel(level: 1, materials: [RequiredMaterial(itemId: "metal_parts", quantity: 20), RequiredMaterial(itemId: "rubber_parts", quantity: 30)]),
        BenchLevel(level: 2, materials: [
          RequiredMaterial(itemId: "rusted_tools", quantity: 3),
          RequiredMaterial(itemId: "mechanical_components", quantity: 5),
          RequiredMaterial(itemId: "wasp_driver", quantity: 8)
        ]),
        BenchLevel(level: 3, materials: [
          RequiredMaterial(itemId: "rusted_gear", quantity: 3),
          RequiredMaterial(itemId: "advanced_mechanical_components", quantity: 5),
          RequiredMaterial(itemId: "sentinel_firing_core", quantity: 4)
        ]),
      ],
    ),

    // 3. TEÇHİZAT TEZGAHI (Gear Bench)
    Bench(
      id: "gear_bench",
      name: "Teçhizat Tezgahı",
      levels: [
        BenchLevel(level: 1, materials: [RequiredMaterial(itemId: "plastic_parts", quantity: 25), RequiredMaterial(itemId: "fabric", quantity: 30)]),
        BenchLevel(level: 2, materials: [
          RequiredMaterial(itemId: "power_cable", quantity: 3),
          RequiredMaterial(itemId: "electrical_components", quantity: 5),
          RequiredMaterial(itemId: "hornet_driver", quantity: 5)
        ]),
        BenchLevel(level: 3, materials: [
          RequiredMaterial(itemId: "industrial_battery", quantity: 3),
          RequiredMaterial(itemId: "advanced_electrical_components", quantity: 5),
          RequiredMaterial(itemId: "bastion_cell", quantity: 6)
        ]),
      ],
    ),

    // 4. TIBBİ LABORATUVAR (Medical Lab)
    Bench(
      id: "medical_lab",
      name: "Tıbbi Laboratuvar",
      levels: [
        BenchLevel(level: 1, materials: [RequiredMaterial(itemId: "fabric", quantity: 50), RequiredMaterial(itemId: "arc_alloy", quantity: 6)]),
        BenchLevel(level: 2, materials: [
          RequiredMaterial(itemId: "cracked_bioscanner", quantity: 2),
          RequiredMaterial(itemId: "durable_cloth", quantity: 5),
          RequiredMaterial(itemId: "tick_pod", quantity: 8)
        ]),
        BenchLevel(level: 3, materials: [
          RequiredMaterial(itemId: "rusted_shut_medical_kit", quantity: 3),
          RequiredMaterial(itemId: "antiseptic", quantity: 8),
          RequiredMaterial(itemId: "surveyor_vault", quantity: 5)
        ]),
      ],
    ),

    // 5. PATLAYICI İSTASYONU (Explosives Station)
    Bench(
      id: "explosives_station",
      name: "Patlayıcı İstasyonu",
      levels: [
        BenchLevel(level: 1, materials: [RequiredMaterial(itemId: "chemicals", quantity: 50), RequiredMaterial(itemId: "arc_alloy", quantity: 6)]),
        BenchLevel(level: 2, materials: [
          RequiredMaterial(itemId: "synthesized_fuel", quantity: 3),
          RequiredMaterial(itemId: "crude_explosives", quantity: 5),
          RequiredMaterial(itemId: "pop_trigger", quantity: 5)
        ]),
        BenchLevel(level: 3, materials: [
          RequiredMaterial(itemId: "laboratory_reagents", quantity: 3),
          RequiredMaterial(itemId: "explosive_compound", quantity: 5),
          RequiredMaterial(itemId: "rocketeer_driver", quantity: 3)
        ]),
      ],
    ),

    // 6. ALET İSTASYONU (Utility Station)
    Bench(
      id: "utility_station",
      name: "Alet İstasyonu",
      levels: [
        BenchLevel(level: 1, materials: [RequiredMaterial(itemId: "plastic_parts", quantity: 50), RequiredMaterial(itemId: "arc_alloy", quantity: 6)]),
        BenchLevel(level: 2, materials: [
          RequiredMaterial(itemId: "damaged_heat_sink", quantity: 2),
          RequiredMaterial(itemId: "electrical_components", quantity: 5),
          RequiredMaterial(itemId: "snitch_scanner", quantity: 6)
        ]),
        BenchLevel(level: 3, materials: [
          RequiredMaterial(itemId: "fried_motherboard", quantity: 3),
          RequiredMaterial(itemId: "advanced_electrical_components", quantity: 5),
          RequiredMaterial(itemId: "leaper_pulse_unit", quantity: 4)
        ]),
      ],
    ),

    // 7. DÖNÜŞTÜRÜCÜ (Refiner)
    Bench(
      id: "refiner",
      name: "Dönüştürücü",
      levels: [
        BenchLevel(level: 1, materials: [RequiredMaterial(itemId: "metal_parts", quantity: 60), RequiredMaterial(itemId: "arc_powercell", quantity: 5)]),
        BenchLevel(level: 2, materials: [
          RequiredMaterial(itemId: "toaster", quantity: 3),
          RequiredMaterial(itemId: "arc_motion_core", quantity: 5),
          RequiredMaterial(itemId: "fireball_burner", quantity: 8)
        ]),
        BenchLevel(level: 3, materials: [
          RequiredMaterial(itemId: "motor", quantity: 3),
          RequiredMaterial(itemId: "arc_circuitry", quantity: 10),
          RequiredMaterial(itemId: "bombardier_cell", quantity: 6)
        ]),
      ],
    ),
  ];
}
