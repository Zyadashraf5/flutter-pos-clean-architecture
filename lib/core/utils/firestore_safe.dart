/// Ensures values written to Firestore are safe (no NaN/Infinity).
/// Prevents C++ runtime abort() on Windows when Firestore SDK receives invalid doubles.
class FirestoreSafe {
  FirestoreSafe._();

  static double doubleValue(double value) {
    if (value.isNaN || value.isInfinite) return 0.0;
    return value;
  }

  static int intValue(int value) => value;
}
