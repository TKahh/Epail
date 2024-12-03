import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtils {
  static String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8('toikhongbietmatkhauvanooneknows1');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }
  static String decryptPassword(String encryptedData) {
    final key = encrypt.Key.fromUtf8('toikhongbietmatkhauvanooneknows1');
    
    // Split the IV and the encrypted password
    final parts = encryptedData.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedPassword = parts[1];

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt64(encryptedPassword, iv: iv);
  }
}
