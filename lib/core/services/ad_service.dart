import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google AdMob configuration + helpers.
///
/// Currently uses Google's official TEST ad unit IDs so real AdMob ads render
/// immediately. To earn revenue, replace the IDs below with your own from the
/// AdMob console, and set your AdMob App ID in AndroidManifest.xml
/// (com.google.android.gms.ads.APPLICATION_ID).
class AdService {
  AdService._();

  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    try {
      await MobileAds.instance.initialize();
      _inited = true;
    } catch (e) {
      debugPrint('[Ads] init failed: $e');
    }
  }

  // ── Ad unit IDs ──────────────────────────────────────────────────────────
  static String get bannerUnitId => Platform.isAndroid
      ? 'ca-app-pub-7523188409057069/3733731991' // 실제 배너
      : 'ca-app-pub-3940256099942544/2934735716';

  // TODO: 보상형 광고단위 ID 받는 대로 교체 (현재 테스트 ID)
  static String get rewardedUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // test rewarded
      : 'ca-app-pub-3940256099942544/1712485313';
}
