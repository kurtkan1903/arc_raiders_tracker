import '../models/patch_note.dart';
import 'patch_1_23_0.dart';
import 'patch_1_22_1.dart';
import 'patch_1_22_0.dart';
import 'patch_1_21_0.dart';
import 'patch_1_20_0.dart';
import 'patch_1_19_0.dart';

class PatchManager {
  static List<PatchNote> get allPatches {
    final patches = [
      patch_1_23_0,
      patch_1_22_1,
      patch_1_22_0,
      patch_1_21_0,
      patch_1_20_0,
      patch_1_19_0,
    ];
    
    // Tarihe göre yeniden eskiye sırala
    patches.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
    return patches;
  }
}
