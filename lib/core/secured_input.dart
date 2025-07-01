import 'package:flutter/material.dart';
import 'package:flutter_defend/core/sql_injection.dart';
import 'package:flutter_defend/widgets/secureinputfield.dart';
import 'package:no_screenshot/no_screenshot.dart';

/// 安全输入封装类，提供对用户输入行为的强化保护能力。
///
/// 本类主要用于在应用中快速接入安全输入策略，包括：
/// - SQL 注入特征检测（基于关键词、模式）
/// - 屏幕截图与录屏防护（可选）
/// - 输入框焦点管理（点击非输入区域自动取消焦点）
///
/// 支持将普通的 [TextField] 转换为具备验证能力的 [TextFormField]，
/// 同时注入自动防注入校验器、截图保护行为等安全逻辑。
class SecureInput {
  /// 内部默认验证器：用于检测用户输入中是否包含潜在的 SQL 注入特征。
  ///
  /// 若未在 [wrapTextField] 中传入自定义 [validator]，则使用本方法作为默认验证器。
  ///
  /// 输入内容一旦命中注入关键字（如 `SELECT`、`OR 1=1`、`--` 等），将返回指定的 [messageForViolation]。
  /// 若未命中注入模式，则返回 `null`，表示验证通过。
  ///
  ///  此方法为私有方法，外部不可直接调用，推荐统一通过 [wrapTextField] 使用。
  String? _validator(String? userInput, {String? messageForViolation}) {
    return SQLInjection().containsInjection(userInput)
        ? messageForViolation
        : null;
  }

  /// 包装并返回一个安全版本的输入框组件。
  ///
  /// 使用方式：将任意一个已存在的 [TextField] 实例传入，系统将提取其关键配置项（如 controller、obscureText、decoration 等），
  /// 并封装成具备 SQL 注入防护、焦点监听、表单验证能力的 [TextFormField]。
  ///
  /// 参数说明：
  ///
  /// - [field]：传入原始的 TextField（只使用其配置，不直接渲染该组件）
  /// - [validator]：可选，自定义表单验证函数。若为空，则默认启用 SQL 注入模式识别。
  /// - [messageForViolation]：可选，定义 SQL 注入命中时返回的错误提示信息，默认提示为 `"检测到非法操作，请停止尝试注入攻击！"`
  /// - [preventScreenshot]：可选，是否开启屏幕截图与录屏防护功能。默认启用（true）。
  ///
  ///  推荐使用方式
  ///  [usage]
  /// ```dart
  ///  SecureInput().wrapTextField(
  ///     TextField(
  ///      controller: controller,
  ///      obscureText: true,
  ///      decoration: InputDecoration(labelText: "密码"),
  ///     ),
  ///   );
  /// ```
  ///
  ///  注意：
  /// - 该方法不会直接修改原始 TextField，也不会复用该组件，仅提取其参数进行安全封装。
  /// - 若 field.controller 为空，使用该方法将抛出运行时异常。
  Widget wrapTextField(
    TextField field, {
    String? Function(String?)? validator,
    String? messageForViolation = "检测到非法操作，请停止尝试注入攻击！",
    bool? preventScreenshot = true,
  }) {
    // 可选开启截图与录屏防护（异步方式，在生命周期外执行）
    if (preventScreenshot == true) {
      NoScreenshot.instance.screenshotOn();
    }

    return Listener(
      // 点击空白区域时，自动取消输入框焦点（提升 UX 体验）
      onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: AbsorbPointer(
        absorbing: false, // 明确设置为可交互（否则将阻止用户输入）
        child: SecureInputField(
          controller: field.controller!, // 强依赖 controller，需确保已绑定
          obscureText: field.obscureText,
          decoration: field.decoration,
          keyboardType: field.keyboardType,
          validator: validator ??
              (input) {
                return _validator(
                  input,
                  messageForViolation: messageForViolation,
                );
              },
        ),
      ),
    );
  }

  /// 关闭屏幕截图与录屏防护，恢复为默认状态。
  ///
  /// - Android 平台：清除 FLAG_SECURE，允许系统截图与录屏
  /// - iOS 平台：通过平台通道调用原生代码以移除截图防护
  ///
  /// 使用场景：
  /// - 离开敏感输入页面时主动调用，释放 FLAG_SECURE
  /// - 配合 [wrapTextField] 中的 `preventScreenshot` 配置使用
  ///
  /// 注意：
  /// 此调用为异步方法，调用后需确保原生层已完成状态恢复。
  Future<void> allowScreenshot() async {
    final noScreenshot = NoScreenshot.instance;
    await noScreenshot.screenshotOff();
  }
}
