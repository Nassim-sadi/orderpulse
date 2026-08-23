abstract final class AppConstants {
  static const verificationWindow = Duration(minutes: 15);
  static const driverStatusWindow = Duration(minutes: 10);
  static const callLogLookbackWindow = Duration(hours: 1);
  static const defaultTrustScore = 100;
  static const unverifiedDeclinePenalty = 5;
  static const noResponsePenalty = 5;
  static const provenLiePenalty = 10;
  static const trustFloor = 0;
}
