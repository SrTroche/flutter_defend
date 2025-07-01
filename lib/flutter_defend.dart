library flutter_defend;

import 'package:flutter_defend/core/jailbreadk.dart';
import 'package:flutter_defend/core/secured_input.dart';
import 'package:flutter_defend/core/secured_storage.dart';
import 'package:flutter_defend/core/sql_injection.dart';

/// FlutterDefend 是统一的安全能力聚合类，
/// 提供输入防护、本地存储加密、越狱/root 检测等基础能力。
///
/// 本类可作为开发者安全控制的统一入口，避免对底层模块的直接依赖，
/// 实现业务解耦、统一升级和安全策略落地。
///
/// 建议在应用启动阶段初始化必要组件，并通过静态方法/属性调用。
class FlutterDefend {
  /// SQL 注入检测器：
  /// 提供基于关键词匹配的注入尝试识别能力。
  /// 推荐用于表单输入、接口参数等场景。
  ///
  /// 示例：
  /// ```dart
  /// if (FlutterDefend.sqlInjection.containsInjection(userInput)) {
  ///   拒绝提交
  /// }
  /// ```
  static final SQLInjection sqlInjection = SQLInjection();

  /// 安全输入封装器：
  /// 支持将原始 TextField 进行包装，增强如下安全特性：
  /// - 防止粘贴、长按、截屏
  /// - 防止注入类字符串输入
  /// - 支持验证逻辑注入
  ///
  /// 用于敏感信息输入，如密码、支付验证码等。
  static final SecureInput secureInput = SecureInput();

  /// 默认本地加密存储器：
  /// 使用凯撒密码变体进行基本本地字符串加密，
  /// 适用于中低敏感数据的本地持久化存储（如用户偏好、Token）。
  ///
  /// 默认使用 "default_passphrase" 作为偏移量来源。
  /// 不推荐用于需要动态密钥的场景。
  static final SecuredStorage secureStorage = SecuredStorage(
    passphrase: 'default_passphrase',
  );

  /// 越狱与 Root 检测器：
  /// 提供运行时的系统完整性判断，
  /// 可用于敏感操作前的安全状态确认。
  ///
  /// 检测包括但不限于：
  /// - iOS 越狱路径
  /// - Android Root 工具痕迹
  ///
  /// 示例：
  /// ```dart
  /// final compromised = await FlutterDefend.jailbreak.isDeviceCompromised();
  /// if (compromised) {
  ///   阻止后续行为
  /// }
  /// ```
  static final Jailbreak jailbreak = Jailbreak();

  /// 创建带动态密钥的本地加密存储实例。
  ///
  /// 适用于登录态之后，通过用户 Token 或密钥派生加密通道的场景。
  /// 提供 `isOneWayEncryption` 参数用于控制是否启用不可逆加密（即哈希模式）。
  ///
  /// 示例：
  /// ```dart
  /// final userStorage = FlutterDefend.withPassphrase("session_key_123");
  /// await userStorage.write("email", "user@domain.com");
  /// ```
  static SecuredStorage withPassphrase(String passphrase,
      {bool oneWay = false}) {
    return SecuredStorage(passphrase: passphrase, isOneWayEncryption: oneWay);
  }
}
