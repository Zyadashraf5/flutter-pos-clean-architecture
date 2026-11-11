// CLI fixture generator: stdout is the intended output.
// ignore_for_file: avoid_print
import 'package:bcrypt/bcrypt.dart';
void main() { print(BCrypt.hashpw('demo-only-password', BCrypt.gensalt(logRounds: 10))); }
