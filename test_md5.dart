import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  final fileName = 'Green_Light_Stick.png';
  final bytes = utf8.encode(fileName);
  final digest = md5.convert(bytes).toString();
  final a = digest.substring(0, 1);
  final ab = digest.substring(0, 2);
  
  print('FileName: $fileName');
  print('MD5: $digest');
  print('Path: w/images/$a/$ab/$fileName');
}
