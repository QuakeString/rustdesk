import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hbb/common.dart';

/// A [WidgetsFlutterBinding] that zooms the whole UI by [kUiScale].
///
/// Flutter's Linux (GTK) embedder only reports GDK's integer scale as the
/// device pixel ratio, so fractional desktop scales such as KDE Plasma's 125%
/// or 150% on X11 are ignored. This binding multiplies the device pixel ratio
/// used for layout and painting by [kUiScale], and converts incoming pointer
/// positions to match. [scaleMediaQueryData] does the same for [MediaQuery].
class UiScaledBinding extends WidgetsFlutterBinding {
  /// Returns the binding, creating a [UiScaledBinding] if [kUiScale] is not
  /// 1.0. Call it instead of [WidgetsFlutterBinding.ensureInitialized].
  static WidgetsBinding ensureInitialized() {
    if (isUiScaled) {
      try {
        WidgetsBinding.instance;
      } catch (_) {
        UiScaledBinding();
      }
    }
    return WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  void initInstances() {
    super.initInstances();
    // GestureBinding converts physical positions to logical ones with the
    // view's (unscaled) device pixel ratio. Pre-divide by kUiScale so the
    // result matches the scaled layout.
    final handler = platformDispatcher.onPointerDataPacket;
    platformDispatcher.onPointerDataPacket = (ui.PointerDataPacket packet) {
      handler?.call(ui.PointerDataPacket(
          data: packet.data.map(_scalePointerData).toList()));
    };
  }

  @override
  ViewConfiguration createViewConfigurationFor(RenderView renderView) {
    final view = renderView.flutterView;
    final devicePixelRatio = uiDevicePixelRatio(view);
    final physicalConstraints =
        BoxConstraints.fromViewConstraints(view.physicalConstraints);
    return ViewConfiguration(
      physicalConstraints: physicalConstraints,
      logicalConstraints: physicalConstraints / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }

  static ui.PointerData _scalePointerData(ui.PointerData d) {
    final s = kUiScale;
    return ui.PointerData(
      viewId: d.viewId,
      embedderId: d.embedderId,
      timeStamp: d.timeStamp,
      change: d.change,
      kind: d.kind,
      signalKind: d.signalKind,
      device: d.device,
      pointerIdentifier: d.pointerIdentifier,
      physicalX: d.physicalX / s,
      physicalY: d.physicalY / s,
      physicalDeltaX: d.physicalDeltaX / s,
      physicalDeltaY: d.physicalDeltaY / s,
      buttons: d.buttons,
      obscured: d.obscured,
      synthesized: d.synthesized,
      pressure: d.pressure,
      pressureMin: d.pressureMin,
      pressureMax: d.pressureMax,
      distance: d.distance,
      distanceMax: d.distanceMax,
      size: d.size,
      radiusMajor: d.radiusMajor / s,
      radiusMinor: d.radiusMinor / s,
      radiusMin: d.radiusMin / s,
      radiusMax: d.radiusMax / s,
      orientation: d.orientation,
      tilt: d.tilt,
      platformData: d.platformData,
      scrollDeltaX: d.scrollDeltaX / s,
      scrollDeltaY: d.scrollDeltaY / s,
      panX: d.panX / s,
      panY: d.panY / s,
      panDeltaX: d.panDeltaX / s,
      panDeltaY: d.panDeltaY / s,
      scale: d.scale,
      rotation: d.rotation,
    );
  }
}
