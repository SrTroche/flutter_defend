import 'package:flutter/material.dart';
import 'package:flutter_defend/core/sql_injection.dart';
import 'package:no_screenshot/no_screenshot.dart';

/// 安全输入框组件（SecureInputField）
///
/// 用于构建一个具备增强安全性的输入表单组件，适用于涉及敏感信息的 UI 场景（如：账号、密码、密保、交易 PIN 等）。
///
/// 该组件在传统 TextFormField 基础上增加以下特性：
///
/// -SQL 注入特征检测（默认启用）
/// -粘贴行为禁止（可选）
/// -屏幕截图与录屏防护（自动启用/恢复）
/// -禁止输入联想/纠错（提升保密性）
///
/// 配合 `flutter_defend` 安全库使用，适用于需要输入加固的企业 App、金融系统、CTF 类平台等高安全场景。
class SecureInputField extends StatefulWidget {
  /// 文本控制器，用于控制/获取输入框内容。
  ///
  /// 此字段为必传，所有表单行为将依赖该 controller 进行管理。
  final TextEditingController controller;

  /// 是否启用密码模式（字符隐藏），默认关闭。
  ///
  /// 启用后将使用 obscuring character 替代真实输入（如用于密码框等）。
  final bool obscureText;

  /// 可选的输入验证器函数（FormField validator）。
  ///
  /// 若未提供，将自动启用内置的 SQL 注入检测器。
  /// 若自定义函数存在，则完全覆盖默认校验逻辑。
  final String? Function(String?)? validator;

  /// 是否禁止屏幕截图与录屏，默认关闭。
  ///
  /// 启用时将在组件初始化期间自动调用原生防截图接口（基于 no_screenshot 插件）。
  /// 页面销毁后自动恢复截图权限，无需额外调用。
  final bool preventScreenshot;

  /// 是否禁止用户粘贴内容，默认关闭。
  ///
  /// 启用后将禁用长按弹出的粘贴菜单，防止复制攻击 Payload。
  final bool preventPaste;

  /// 输入框装饰（Decoration），用于控制样式、标签、边框等。
  ///
  /// 可选参数，若未设置将继承默认 Material 样式。
  final InputDecoration? decoration;

  /// 键盘输入类型（如 text、number、email、phone 等）。
  ///
  /// 默认为普通文本类型（TextInputType.text）。
  final TextInputType keyboardType;

  const SecureInputField({
    super.key,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.preventScreenshot = false,
    this.preventPaste = false,
    this.decoration,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<SecureInputField> createState() => _SecureInputFieldState();
}

/// 安全输入框内部状态类，负责处理生命周期中涉及的平台级副作用。
///
/// 当前主要处理以下副作用：
/// - 进入页面时启用截图防护（FLAG_SECURE）
/// - 离开页面时自动恢复截图权限
///
/// 若后续扩展如录音禁用、剪贴板清空等，可在此管理。
class _SecureInputFieldState extends State<SecureInputField> {
  @override
  void initState() {
    super.initState();

    // 若启用截图保护，初始化时设置平台 FLAG_SECURE（禁止录屏/截图）
    if (widget.preventScreenshot) {
      NoScreenshot.instance.screenshotOff();
    }
  }

  @override
  void dispose() {
    // 页面销毁时恢复截图能力，避免影响其他页面
    if (widget.preventScreenshot) {
      NoScreenshot.instance.screenshotOn();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      validator: widget.validator ??
          (input) {
            if (SQLInjection().containsInjection(input)) {
              return "检测到非法输入，请停止注入尝试";
            }
            return null;
          },
      enableInteractiveSelection: !widget.preventPaste, // 禁用粘贴操作
      enableSuggestions: false, // 禁用输入联想
      autocorrect: false, // 禁用自动拼写纠错
    );
  }
}
