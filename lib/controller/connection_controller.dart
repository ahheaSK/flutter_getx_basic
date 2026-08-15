import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/util/logger.dart';
import '../core/value/app_color.dart';
import '../data/service/sse_service.dart';

/// Watches the device's network state and reacts when it changes.
///
/// Registered permanently in `DependencyInjectionBinding`, so it starts
/// listening at launch and keeps listening for the whole app run.
///
/// **What this does and does not tell you.** `connectivity_plus` reports the
/// *interface* — wifi, mobile, none — not whether the internet is actually
/// reachable. A phone joined to a café hotspot that needs a login still reports
/// `wifi`. Treat this as "is there any point trying a request", and let the API
/// layer report real failures.
class ConnectionController extends GetxController {
  /// 0 = none, 1 = wifi, 2 = mobile, 3 = other (ethernet, VPN…).
  final connectionType = 0.obs;

  final isConnected = true.obs;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _readCurrent();
    // connectivity_plus 6+ emits a LIST, because a device can hold several
    // interfaces at once (wifi and mobile together). Version 5 emitted a single
    // ConnectivityResult — code written against it will not compile here.
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _readCurrent() async {
    try {
      _update(await _connectivity.checkConnectivity());
    } catch (e) {
      // Never leave the state unset: if the platform call fails, assume online
      // and let the first real request produce the error.
      Logger.e('Connectivity', e);
      _update(const <ConnectivityResult>[ConnectivityResult.wifi]);
    }
  }

  void _update(List<ConnectivityResult> results) {
    final bool wasConnected = isConnected.value;

    if (results.contains(ConnectivityResult.wifi)) {
      connectionType.value = 1;
    } else if (results.contains(ConnectivityResult.mobile)) {
      connectionType.value = 2;
    } else if (results.isEmpty ||
        results.every((ConnectivityResult r) => r == ConnectivityResult.none)) {
      connectionType.value = 0;
    } else {
      connectionType.value = 3; // ethernet, VPN, bluetooth…
    }

    isConnected.value = connectionType.value != 0;
    Logger.d(
      'Connectivity',
      'type=${connectionType.value} online=${isConnected.value}',
    );

    if (!isConnected.value) {
      _showOfflineBanner();
      return;
    }

    // Came back online.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    // Only act on an actual transition, not on every duplicate event.
    if (!wasConnected) {
      // The SSE stream died with the network. Re-open it rather than waiting
      // for its own 5-second retry.
      if (Get.isRegistered<SseService>()) {
        Get.find<SseService>().connect();
      }
    }
  }

  /// A permanent bar pinned to the bottom until the network returns.
  ///
  /// Deliberately *not* `Get.offAllNamed(...)`: resetting the navigation stack
  /// on every connectivity blip would throw away a half-filled form each time
  /// the wifi flickers. The banner informs; the screens stay put.
  void _showOfflineBanner() {
    if (Get.isSnackbarOpen) return;

    Get.rawSnackbar(
      messageText: Text(
        'No internet connection'.tr,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      icon: const Icon(Icons.wifi_off, color: Colors.white, size: 28),
      backgroundColor: AppColor.danger,
      isDismissible: false,
      // Effectively "until dismissed by code" — cleared when the network
      // returns, in _update above.
      duration: const Duration(days: 1),
      margin: EdgeInsets.zero,
      snackStyle: SnackStyle.GROUNDED,
    );
  }
}
