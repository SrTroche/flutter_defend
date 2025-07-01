library flutter_defend;

import 'package:flutter_defend/core/secured_input.dart';

/// flutter_defend 是一个用于增强 Flutter 应用安全性的工具库，
/// 提供以下核心功能模块：
///
/// - SQL 注入检测器（SQLInjection）
/// - 安全输入包装器（SecureInput）
/// - 本地加密存储器（SecuredStorage）
///
/// 本文件为公开库的统一导出接口，可直接通过 `FlutterDefend.xxx` 使用全部功能。

import 'package:flutter_defend/core/secured_storage.dart';
import 'package:flutter_defend/core/sql_injection.dart';

class FlutterDefend {
  /// SQL 注入检测器，用于检测潜在 SQL 注入关键字
  static final SQLInjection sqlInjection = SQLInjection();

  /// 用于包裹 TextField，增强验证与屏幕安全性
  static final SecureInput secureInput = SecureInput();

  /// 默认本地加密存储器（必须提供默认 passphrase）
  /// 注意：此默认实现不适用于动态密钥生成场景
  static final SecuredStorage secureStorage = SecuredStorage(
    passphrase: 'default_passphrase',
  );
}
