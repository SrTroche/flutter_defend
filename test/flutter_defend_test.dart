import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_defend/flutter_defend.dart';

void main() {
  group('FlutterDefend 安全模块聚合测试', () {
    test('SQL 注入识别测试', () {
      expect(
          FlutterDefend.sqlInjection.containsInjection("SELECT * FROM users"),
          isTrue);
      expect(FlutterDefend.sqlInjection.containsInjection("正常输入"), isFalse);
    });

    test('默认存储器加解密测试', () async {
      await FlutterDefend.secureStorage.write("token", "abc123");
      final result = await FlutterDefend.secureStorage.read("token");
      expect(result, equals("abc123"));
    });

    test('动态密钥加密存储器隔离测试', () async {
      final storage1 = FlutterDefend.withPassphrase("key1");
      final storage2 = FlutterDefend.withPassphrase("key2");

      await storage1.write("data", "apple");
      final r1 = await storage1.read("data");
      final r2 = await storage2.read("data");

      expect(r1, equals("apple"));
      expect(r2, isNull); // 因为密钥不同，解不出来
    });

    test('不可逆加密测试（哈希）', () async {
      final hashedStorage =
          FlutterDefend.withPassphrase("oneway", oneWay: true);
      await hashedStorage.write("key", "secret");
      final result = await hashedStorage.read("key");
      expect(result, isNot(equals("secret")));
    });

    test('越狱检测模拟（伪异步测试）', () async {
      final compromised = await FlutterDefend.jailbreak.isDeviceCompromised();
      // NOTE: 真机环境不一定能测试越狱，这里主要验证返回类型
      expect(compromised, isA<bool>());
    });
  });
}
