import 'package:bcrypt/bcrypt.dart';

/// Never store plain passwords. Use hash before saving and verify on login.
class PasswordHash {
  PasswordHash._();

  static const int _workFactor = 10;

  static String hash(String plainPassword) {
    return BCrypt.hashpw(plainPassword, BCrypt.gensalt(logRounds: _workFactor));
  }

  static bool verify(String plainPassword, String storedHash) {
    return BCrypt.checkpw(plainPassword, storedHash);
  }
}
