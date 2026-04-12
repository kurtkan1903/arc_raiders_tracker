import json
import re

user_data = """
  GameItem(fileName: "Bp_Combat_Mk._III_(Aggressive).webp", nameTr: "Çatışma Mod III (Saldırgan)"),
  GameItem(fileName: "Bp_Combat_Mk._III_(Flanking).webp", nameTr: "Çatışma Mod III (Baskın)"),
  GameItem(fileName: "Bp_Tactical_Mk._III_(Defensive).webp", nameTr: "Taktiksel Mod III (Savunma)"),
  GameItem(fileName: "Bp_Tactical_Mk._III_(Healing).webp", nameTr: "Taktiksel Mod III (İyileştirme)"),
  GameItem(fileName: "Bp_Tactical_Mk._III_(Revival).webp", nameTr: "Taktiksel Mod III (Diriltici)"),
  GameItem(fileName: "Bp_Looting_Mk._III_(Safekeeper).webp", nameTr: "Yağmalama Mod III (Koruyucu)"),
  GameItem(fileName: "Bp_Looting_Mk._III_(Survivor).webp", nameTr: "Yağmalama Mod III (Hayatta Kalan)"),
  GameItem(fileName: "Bp_Anvil.webp", nameTr: "Örs"),
  GameItem(fileName: "Bp_Aphelion.webp", nameTr: "Aphelion"),
  GameItem(fileName: "Bp_Bettina.webp", nameTr: "Bettina"),
  GameItem(fileName: "Bp_Bobcat.webp", nameTr: "Vaşak"),
  GameItem(fileName: "Bp_Burletta.webp", nameTr: "Burletta"),
  GameItem(fileName: "Bp_Equalizer.webp", nameTr: "Dengeleyici"),
  GameItem(fileName: "Bp_Hullcracker.webp", nameTr: "KabukKıran"),
  GameItem(fileName: "Bp_Il_Toro.webp", nameTr: "IL Toro"),
  GameItem(fileName: "Bp_Jupiter.webp", nameTr: "Erendiz"),
  GameItem(fileName: "Bp_Osprey.webp", nameTr: "Kartal"),
  GameItem(fileName: "Bp_Tempest.webp", nameTr: "Bora"),
  GameItem(fileName: "Bp_Torrente.webp", nameTr: "Torrente"),
  GameItem(fileName: "Bp_Venator.webp", nameTr: "Avcı"),
  GameItem(fileName: "Bp_Vulcano.webp", nameTr: "Yanardağ"),
  GameItem(fileName: "Bp_Showstopper.webp", nameTr: "Efsane"),
  GameItem(fileName: "Bp_Deadline.webp", nameTr: "Mühlet"),
  GameItem(fileName: "Bp_Wolfpack.webp", nameTr: "Kurt Sürüsü"),
  GameItem(fileName: "Bp_Trailblazer.webp", nameTr: "Yol Açan"),
  GameItem(fileName: "Bp_Barricade_Kit.webp", nameTr: "Barikat Kiti"),
  GameItem(fileName: "Bp_Blaze_Grenade.webp", nameTr: "Alev Bombası"),
  GameItem(fileName: "Bp_Defibrillator.webp", nameTr: "Şok Cihazı"),
  GameItem(fileName: "Bp_Explosive_Mine.webp", nameTr: "Patlayıcı Mayın"),
  GameItem(fileName: "Bp_Fireworks_Box.webp", nameTr: "Havai Fişek Kutusu"),
  GameItem(fileName: "Bp_Gas_Mine.webp", nameTr: "Gaz Mayını"),
  GameItem(fileName: "Bp_Jolt_Mine.webp", nameTr: "Şok Mayını"),
  GameItem(fileName: "Bp_Lure_Grenade.webp", nameTr: "Yem Bombası"),
  GameItem(fileName: "Bp_Pulse_Mine.webp", nameTr: "Darbeli Mayın"),
  GameItem(fileName: "Bp_Remote_Raider_Flare.webp", nameTr: "Kumandalı Raider Fişeği"),
  GameItem(fileName: "Bp_Seeker_Grenade.webp", nameTr: "Güdümlü Bomba"),
  GameItem(fileName: "Bp_Smoke_Grenade.webp", nameTr: "Sis Bombası"),
  GameItem(fileName: "Bp_Tagging_Grenade.webp", nameTr: "İşaretleme Bombası"),
  GameItem(fileName: "Bp_Trigger_Nade.webp", nameTr: "Tetikleme Bombası"),
  GameItem(fileName: "Bp_Vita_Shot.webp", nameTr: "Sağlık İğnesi"),
  GameItem(fileName: "Bp_Vita_Spray.webp", nameTr: "Sağlık Spreyi"),
  GameItem(fileName: "Bp_Angled_Grip_II.webp", nameTr: "Açılı Tutamaç II"),
  GameItem(fileName: "Bp_Angled_Grip_III.webp", nameTr: "Açılı Tutamaç III"),
  GameItem(fileName: "Bp_Vertical_Grip_II.webp", nameTr: "Dikey Tutamaç II"),
  GameItem(fileName: "Bp_Vertical_Grip_III.webp", nameTr: "Dikey Tutamaç III"),
  GameItem(fileName: "Bp_Extended_Light_Mag_II.webp", nameTr: "Uzatılmış Hafif Şarjör II"),
  GameItem(fileName: "Bp_Extended_Light_Mag_III.webp", nameTr: "Uzatılmış Hafif Şarjör III"),
  GameItem(fileName: "Bp_Extended_Medium_Mag_II.webp", nameTr: "Uzatılmış Orta Şarjör II"),
  GameItem(fileName: "Bp_Extended_Medium_Mag_III.webp", nameTr: "Uzatılmış Orta Şarjör III"),
  GameItem(fileName: "Bp_Extended_Shotgun_Mag_II.webp", nameTr: "Uzatılmış Av Tüfeği Şarjörü II"),
  GameItem(fileName: "Bp_Extended_Shotgun_Mag_III.webp", nameTr: "Uzatılmış Av Tüfeği Şarjörü III"),
  GameItem(fileName: "Bp_Muzzle_Brake_II.webp", nameTr: "Namlu Ağzı Freni II"),
  GameItem(fileName: "Bp_Muzzle_Brake_III.webp", nameTr: "Namlu Ağzı Freni III"),
  GameItem(fileName: "Bp_Compensator_II.webp", nameTr: "Kompansatör II"),
  GameItem(fileName: "Bp_Compensator_III.webp", nameTr: "Kompansatör III"),
  GameItem(fileName: "Bp_Silencer_I.webp", nameTr: "Susturucu I"),
  GameItem(fileName: "Bp_Silencer_II.webp", nameTr: "Susturucu II"),
  GameItem(fileName: "Bp_Shotgun_Silencer.webp", nameTr: "Av Tüfeği Susturucu"),
  GameItem(fileName: "Bp_Shotgun_Choke_II.webp", nameTr: "Av Tüfeği Boğumlu Namlu II"),
  GameItem(fileName: "Bp_Shotgun_Choke_III.webp", nameTr: "Av Tüfeği Boğumlu Namlu III"),
  GameItem(fileName: "Bp_Padded_Stock.webp", nameTr: "Yastıklı Dipçik"),
  GameItem(fileName: "Bp_Stable_Stock_II.webp", nameTr: "Dengeli Dipçik II"),
  GameItem(fileName: "Bp_Stable_Stock_III.webp", nameTr: "Dengeli Dipçik III"),
  GameItem(fileName: "Bp_Lightweight_Stock.webp", nameTr: "Hafif Dipçik"),
  GameItem(fileName: "Bp_Extended_Barrel.webp", nameTr: "Uzatılmış Namlu"),
  GameItem(fileName: "Bp_Snap_Hook.webp", nameTr: "Kanca"),
  GameItem(fileName: "Bp_Light_Gun_Parts.webp", nameTr: "Hafif Silah Parçaları"),
  GameItem(fileName: "Bp_Medium_Gun_Parts.webp", nameTr: "Orta Silah Parçaları"),
  GameItem(fileName: "Bp_Heavy_Gun_Parts.webp", nameTr: "Ağır Silah Parçaları"),
  GameItem(fileName: "Bp_Complex_Gun_Parts.webp", nameTr: "Karmaşık Silah Parçaları"),
  GameItem(fileName: "Bp_Blue_Light_Stick.webp", nameTr: "Mavi Işık Çubuğu"),
  GameItem(fileName: "Bp_Green_Light_Stick.webp", nameTr: "Yeşil Işık Çubuğu"),
  GameItem(fileName: "Bp_Red_Light_Stick.webp", nameTr: "Kırmızı Işık Çubuğu"),
  GameItem(fileName: "Bp_Yellow_Light_Stick.webp", nameTr: "Sarı Işık Çubuğu")
"""

def generate_id(name):
    return re.sub(r"['\(\)\-\. ]", '_', name.lower()).replace('__', '_').strip('_')

matches = re.findall(r'fileName: "(.*?)", nameTr: "(.*?)"', user_data)
blueprints = []

for file_name, name_tr in matches:
    # Bp_Combat_Mk._III_(Aggressive).webp -> Combat Mk. III (Aggressive)
    display_name = file_name.replace("Bp_", "").replace(".webp", "").replace("_", " ")
    
    # Handle Roman numerals and dots
    # Combat Mk. III (Aggressive) -> Combat Mk. 3 (Aggressive) matching names.txt format
    match_name = display_name.replace("Mk. III", "Mk. 3").replace("Mk. II", "Mk. 2").replace("Mk. I", "Mk. 1")
    
    blueprints.append({
        "id": generate_id(match_name),
        "originalName": match_name,
        "nameTr": name_tr,
        "fileName": file_name
    })

with open("blueprints_extracted.json", "w", encoding="utf-8") as f:
    json.dump(blueprints, f, indent=2, ensure_ascii=False)

print(f"Extracted {len(blueprints)} blueprints.")
