import 'package:flutter_root_jailbreak/flutter_root_jailbreak.dart';

/// Jailbreak 是一个封装类，用于检测当前设备是否处于
/// 非受信任状态（如越狱或 root），常用于移动端安全防护场景。
///
/// 使用 `flutter_root_jailbreak` 插件实现平台无感知的越狱/root 检测。
///
/// 适用平台：
/// - iOS：检测是否越狱（Jailbroken）
/// - Android：检测是否已 Root
///
/// 注意：此检测机制为启发式方法，不能 100% 防止高级隐藏（如 Magisk Hide）
/// 推荐搭配设备完整性校验（如 Play Integrity API 或 iOS DeviceCheck）使用。
class Jailbreak {
  /// 异步方法：检测当前设备是否被破解（越狱或 root）
  ///
  /// - 返回 true 表示当前系统存在风险，已越狱或已 root。
  /// - 返回 false 表示系统未发现破解痕迹。
  ///
  /// 可集成到启动逻辑或敏感操作前，如登录、支付、数据加密场景。
  ///
  /// 使用方式：
  /// ```dart
  /// final jailbreak = Jailbreak();
  /// final compromised = await jailbreak.isDeviceCompromised();
  ///
  /// if (compromised) {
  ///   print("当前设备存在安全风险！");
  /// } else {
  ///   print("设备状态正常。");
  /// }
  /// ```
  Future<bool> isDeviceCompromised() async {
    final bool isRooted = await FlutterRootJailbreak.isRooted;
    final bool isJailBroken = await FlutterRootJailbreak.isJailBroken;

    return isRooted || isJailBroken;
  }
}
