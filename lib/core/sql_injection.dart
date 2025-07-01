/// SQL 注入检测工具类（关键词黑名单匹配）
///
/// 本类用于检测用户输入中是否包含潜在的 SQL 注入关键字或注入尝试模式，
/// 采用基于关键词（keyword blacklist）的简单匹配策略，可用于表单输入校验、
/// 防止客户端 SQL 注入探测行为等用途。
///
///  注意：
/// - 本工具仅适用于客户端输入预防用途，无法取代后端数据库层面的安全防护（如参数化查询）
/// - 若需更高安全等级，建议配合服务端 WAF、防火墙规则、AST 分析使用
class SQLInjection {
  /// 黑名单关键字列表，用于检测是否命中 SQL 注入特征。
  ///
  /// 包括 SQL 操作命令（如 SELECT、DROP）、布尔表达式（如 1=1）、注释符号（--、#）、系统关键字（如 xp_cmdshell）等。
  ///
  ///  所有关键词均为小写形式，检测时将对输入进行 `.toLowerCase()` 标准化。
  final List<String> _keywords = const [
    // 基本 DML/DQL/DCL 操作
    'select',
    'insert',
    'update',
    'delete',
    'drop',
    'truncate',
    'exec',
    'execute',
    'union',
    'create',
    'alter',
    'rename',
    'grant',
    'revoke',
    'show',
    'describe',

    // 系统库
    'information_schema',
    'table_schema',

    // 时间延迟攻击
    'sleep',
    'benchmark',

    // 注释语法
    '--',
    '#',
    ';',

    // 布尔型注入
    'or ',
    'and ',
    '1=1',
    '1 = 1',
    "' or",
    '" or',
    "' and",
    '" and',

    // 高危函数和系统对象
    'xp_cmdshell',
    'sysobjects',
    'syscolumns',
    'char(',
    'concat(',
    'cast(',
    'convert(',

    // 文件操作
    'declare',
    'set global',
    'load_file(',
    'outfile',
    'load data',
    'into outfile',
  ];

  /// 判断指定输入内容是否包含 SQL 注入关键字。
  ///
  /// - [input]：待检测内容，支持任意类型（将通过 `.toString()` 转为字符串）。
  /// - 返回值：如果匹配成功（命中黑名单关键词），返回 true；否则返回 false。
  ///
  /// 示例：
  /// ```dart
  /// SQLInjection().containsInjection("SELECT * FROM users");
  /// 返回 true
  /// ```
  ///
  ///  推荐搭配用户输入表单的 validator 一起使用：
  /// ```dart
  /// validator: (value) => SQLInjection().containsInjection(value)
  ///     ? "检测到非法关键词，请勿尝试注入"
  ///     : null;
  /// ```
  bool containsInjection(dynamic input) {
    final content = input.toString().toLowerCase();
    return _keywords.any((k) => content.contains(k));
  }
}
