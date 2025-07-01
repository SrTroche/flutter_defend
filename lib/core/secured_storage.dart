import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecuredStorage 是一个基于 flutter_secure_storage 封装的安全存储类，
/// 提供了基于凯撒加密算法（Caesar Cipher）的轻量级加解密功能，
/// 同时支持单向加密模式（one-way encryption），用于防止解密（类似于哈希处理）。
///
/// ## 参数说明:
/// - [passphrase] 用于派生加密的偏移量（shift）
/// - [isOneWayEncryption] 如果为 true，则启用单向加密，仅可写入，无法解密读取
///
/// ## 使用场景:
/// 可用于保存轻度敏感信息（如 token、用户 ID），
/// 注意：此方案为教学/调试级安全，不适用于高强度加密需求。
class SecuredStorage {
  /// 传入的密码短语，用于生成 Caesar Cipher 的位移量
  final String? passphrase;

  /// 是否启用不可逆的加密（无法解密），适用于 token/hash 场景
  final bool? isOneWayEncryption;

  /// 内部的安全存储实例，使用 flutter_secure_storage 实现平台原生加密存储
  final FlutterSecureStorage storage;

  /// 私有构造函数，仅供 factory 方法使用
  SecuredStorage._internal(this.passphrase, this.isOneWayEncryption)
      : storage = const FlutterSecureStorage();

  /// 构造函数，用于创建 SecuredStorage 实例
  ///
  /// - [passphrase]: 加解密用的密码短语
  /// - [isOneWayEncryption]: 是否启用单向加密，默认为 false
  factory SecuredStorage({
    required String passphrase,
    bool? isOneWayEncryption = false,
  }) {
    return SecuredStorage._internal(passphrase, isOneWayEncryption);
  }

  /// Caesar Cipher 加/解密算法
  ///
  /// - [text]: 输入字符串
  /// - [shift]: 加密位移量，通常由 passphrase 的长度决定
  /// - [decrypt]: 是否执行解密（默认加密）。加密为右移，解密为左移。
  ///
  /// 该方法仅对 ASCII 可打印字符 (32~126) 生效，跳过中文/emoji 等字符
  String cipher(String text, int shift, {bool decrypt = false}) {
    const int base = 32;
    const int range = 95;

    final actualShift = decrypt ? -shift : shift;

    return String.fromCharCodes(text.runes.map((int code) {
      if (code >= base && code <= base + range - 1) {
        return ((code - base + actualShift) % range + range) % range + base;
      } else {
        return code;
      }
    }));
  }

  /// 加密并写入数据到安全存储中
  ///
  /// - [key]: 存储键名
  /// - [value]: 原始明文数据
  ///
  /// 如果启用单向加密，将以不可逆方式存储（即不能解密读取）
  Future<void> write(String key, String value) async {
    final cipheredValue = cipher(
      value,
      passphrase!.length,
      decrypt: isOneWayEncryption!,
    );

    await storage.write(
      key: key,
      value: cipheredValue,
    );

    debugPrint('SecuredStorage [WRITE] $key: $value -> $cipheredValue');
  }

  /// 读取并解密指定键的数据
  ///
  /// - [key]: 存储键名
  ///
  /// 如果启用了单向加密，则会抛出异常（无法解密）
  Future<String?> read(String key) async {
    final encrypted = await storage.read(key: key);
    if (encrypted == null) return null;

    if (isOneWayEncryption == true) {
      throw Exception("One-way encryption is enabled. Cannot decrypt.");
    }

    final decrypted = cipher(encrypted, passphrase!.length, decrypt: true);

    debugPrint('SecuredStorage [READ] $key: $decrypted');
    return decrypted;
  }

  /// 更新指定键的值（覆盖旧值）
  ///
  /// - [key]: 存储键名
  /// - [newValue]: 新的明文值
  ///
  /// 如果键不存在将抛出异常。若启用 one-way 模式，将以相同加密逻辑写入新值。
  Future<void> update(String key, String newValue) async {
    final exists = await storage.containsKey(key: key);
    if (!exists) {
      throw Exception("Key '$key' does not exist. Cannot update.");
    }

    final cipheredValue = cipher(
      newValue,
      passphrase!.length,
      decrypt: isOneWayEncryption!,
    );

    await storage.write(key: key, value: cipheredValue);
    debugPrint('SecuredStorage [UPDATE] $key: $newValue -> $cipheredValue');
  }

  /// 删除指定键的数据
  ///
  /// - [key]: 存储键名
  Future<void> delete(String key) async {
    await storage.delete(key: key);
    debugPrint('SecuredStorage [DELETE] $key');
  }

  /// 读取所有存储项（以键值对 Map 返回）
  ///
  /// 注意：此方法不会对值进行解密，返回的 value 为加密状态
  Future<Map<String, String>> readAll() async {
    final all = await storage.readAll();
    debugPrint('SecuredStorage [READ_ALL]: $all');
    return all;
  }
}
