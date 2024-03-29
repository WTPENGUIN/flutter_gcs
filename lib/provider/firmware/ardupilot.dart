import 'package:dart_mavlink/dialects/ardupilotmega.dart';

class ArdupilotFlightMode {
  final String     modeName;
  final CopterMode customMode;
  final bool       settable;

  ArdupilotFlightMode(this.modeName, this.customMode, this.settable);
}

List<ArdupilotFlightMode> ardupilotFlightModes = [
  ArdupilotFlightMode("STABILIZE",    copterModeStabilize,   true),
  ArdupilotFlightMode("ACRO",         copterModeAcro,        true),
  ArdupilotFlightMode("ALT_HOLD",     copterModeAltHold,     true),
  ArdupilotFlightMode("AUTO",         copterModeAuto,        true),
  ArdupilotFlightMode("GUIDED",       copterModeGuided,      true),
  ArdupilotFlightMode("LOITER",       copterModeLoiter,      true),
  ArdupilotFlightMode("RTL",          copterModeRtl,         true),
  ArdupilotFlightMode("CIRCLE",       copterModeCircle,      true),
  ArdupilotFlightMode("LAND",         copterModeLand,        true),
  ArdupilotFlightMode("DRIFT",        copterModeDrift,       true),
  ArdupilotFlightMode("SPORT",        copterModeSport,       false),
  ArdupilotFlightMode("FLIP",         copterModeFlip,        false),
  ArdupilotFlightMode("AUTOTUNE",     copterModeAutotune,    true),
  ArdupilotFlightMode("POS_HOLD",     copterModePoshold,     true),
  ArdupilotFlightMode("BRAKE",        copterModeBrake,       true),
  ArdupilotFlightMode("THROW",        copterModeThrow,       false),
  ArdupilotFlightMode("AVOID_ADSB",   copterModeAvoidAdsb,   false),
  ArdupilotFlightMode("GUIDED_NOGPS", copterModeGuidedNogps, false),
  ArdupilotFlightMode("SMART_RTL",    copterModeSmartRtl,    true),
  ArdupilotFlightMode("FLOWHOLD",     copterModeFlowhold,    false),
  ArdupilotFlightMode("FOLLOW",       copterModeFollow,      false),
  ArdupilotFlightMode("ZIGZAG",       copterModeZigzag,      false),
  ArdupilotFlightMode("SYSTEMID",     copterModeSystemid,    false),
  ArdupilotFlightMode("AUTOROTATE",   copterModeAutorotate,  false),
  ArdupilotFlightMode("AUTO_RTL",     copterModeAutoRtl,     true),
];

// 전환 가능한 비행 모드인지 탐색
ArdupilotFlightMode? findArduFlightMode(String flightMode) {
  ArdupilotFlightMode? returnMode;
  bool found = false;
  
  for(ArdupilotFlightMode mode in ardupilotFlightModes) {
    if(flightMode.compareTo(mode.modeName) == 0) {
      returnMode = mode;
      found = true;
      break;
    }
  }

  if(found) {
    return returnMode;
  } else {
    return null;
  }
}

String apmGetFlightModeName(CopterMode customMode) {
  String name = 'Unknown';

  for(ArdupilotFlightMode mode in ardupilotFlightModes) {
    if(customMode == mode.customMode) {
      name = mode.modeName;
      break;
    }
  }

  return name;
}