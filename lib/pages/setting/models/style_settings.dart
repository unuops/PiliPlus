import 'dart:io';
import 'dart:math' as math;

import 'package:PiliPlus/common/widgets/custom_toast.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/scale_app.dart';
import 'package:PiliPlus/common/widgets/stateful_builder.dart';
import 'package:PiliPlus/main.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/models/common/dynamic/up_panel_position.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/common/msg/msg_unread_type.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models/common/theme/theme_type.dart';
import 'package:PiliPlus/pages/main/controller.dart';
import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/pages/setting/models/model.dart';
import 'package:PiliPlus/pages/setting/slide_color_picker.dart';
import 'package:PiliPlus/pages/setting/widgets/dual_slider_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/multi_select_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPlus/pages/setting/widgets/slider_dialog.dart';
import 'package:PiliPlus/plugin/pl_player/utils/fullscreen.dart';
import 'package:PiliPlus/utils/extension/file_ext.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/storage.dart';
import 'package:PiliPlus/utils/storage_key.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart' hide StatefulBuilder;
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart' as path;

List<SettingsModel> get styleSettings => [
  if (PlatformUtils.isDesktop) ...[
    const SwitchModel(
      title: '显示窗口标题�?,
      leading: Icon(Icons.window),
      setKey: SettingBoxKey.showWindowTitleBar,
      defaultVal: true,
      needReboot: true,
    ),
    const SwitchModel(
      title: '显示托盘图标',
      leading: Icon(Icons.donut_large_rounded),
      setKey: SettingBoxKey.showTrayIcon,
      defaultVal: true,
      needReboot: true,
    ),
  ],
  if (Platform.isLinux) _useSSDModel(),
  SwitchModel(
    title: '横屏适配',
    subtitle: '启用横屏布局与逻辑，平板、折叠屏等可开启；建议全屏方向设为【不改变当前方向�?,
    leading: const Icon(Icons.phonelink_outlined),
    setKey: SettingBoxKey.horizontalScreen,
    defaultVal: Pref.horizontalScreen,
    onChanged: (value) {
      if (value) {
        autoScreen();
      } else {
        AutoOrientation.portraitUpMode();
      }
    },
  ),
  const SwitchModel(
    title: '改用侧边�?,
    subtitle: '开启后底栏与顶栏被替换，且相关设置失效',
    leading: Icon(Icons.chrome_reader_mode_outlined),
    setKey: SettingBoxKey.useSideBar,
    defaultVal: false,
    needReboot: true,
  ),
  SwitchModel(
    title: 'App字体字重',
    subtitle: '点击设置',
    setKey: SettingBoxKey.appFontWeight,
    defaultVal: false,
    leading: const Icon(Icons.text_fields),
    onChanged: (value) => Get.forceAppUpdate(),
    onTap: _showFontWeightDialog,
  ),
  NormalModel(
    title: '界面缩放',
    getSubtitle: () => '当前缩放比例�?{Pref.uiScale.toStringAsFixed(2)}',
    leading: const Icon(Icons.zoom_in_outlined),
    onTap: _showUiScaleDialog,
  ),
  NormalModel(
    title: '页面过渡动画',
    leading: const Icon(Icons.animation),
    getSubtitle: () => '当前�?{Pref.pageTransition.name}',
    onTap: _showTransitionDialog,
  ),
  const SwitchModel(
    title: '优化平板导航�?,
    leading: Icon(MdiIcons.soundbar),
    setKey: SettingBoxKey.optTabletNav,
    defaultVal: true,
    needReboot: true,
  ),
  const SwitchModel(
    title: 'MD3样式底栏',
    subtitle: 'Material You设计规范底栏，关闭可变窄',
    leading: Icon(Icons.design_services_outlined),
    setKey: SettingBoxKey.enableMYBar,
    defaultVal: true,
    needReboot: true,
  ),
  NormalModel(
    leading: const Icon(Icons.calendar_view_week_outlined),
    title: '列表宽度（dp）限�?,
    getSubtitle: () =>
        '当前: 主页${Pref.recommendCardWidth.toInt()}dp 其他${Pref.smallCardWidth.toInt()}dp，屏幕宽�?${MediaQuery.widthOf(Get.context!).toPrecision(2)}dp。宽度越小列数越多�?,
    onTap: _showCardWidthDialog,
  ),
  SwitchModel(
    title: '视频播放页使用深色主�?,
    leading: const Icon(Icons.dark_mode_outlined),
    setKey: SettingBoxKey.darkVideoPage,
    defaultVal: false,
    onChanged: (value) {
      if (value && MyApp.darkThemeData == null) {
        Get.forceAppUpdate();
      }
    },
  ),
  const SwitchModel(
    title: '动态页启用瀑布�?,
    subtitle: '关闭会显示为单列',
    leading: Icon(Icons.view_array_outlined),
    setKey: SettingBoxKey.dynamicsWaterfallFlow,
    defaultVal: true,
    needReboot: true,
  ),
  NormalModel(
    title: '动态页UP主显示位�?,
    leading: const Icon(Icons.person_outlined),
    getSubtitle: () => '当前�?{Pref.upPanelPosition.label}',
    onTap: _showUpPosDialog,
  ),
  const SwitchModel(
    title: '动态页显示所有已关注UP�?,
    leading: Icon(Icons.people_alt_outlined),
    setKey: SettingBoxKey.dynamicsShowAllFollowedUp,
    defaultVal: false,
    needReboot: true,
  ),
  const SwitchModel(
    title: '动态页展开正在直播UP列表',
    leading: Icon(Icons.live_tv),
    setKey: SettingBoxKey.expandDynLivePanel,
    defaultVal: false,
    needReboot: true,
  ),
  NormalModel(
    title: '动态未读标�?,
    leading: const Icon(Icons.motion_photos_on_outlined),
    getSubtitle: () => '当前标记样式�?{Pref.dynamicBadgeType.desc}',
    onTap: _showDynBadgeDialog,
  ),
  NormalModel(
    title: '消息未读标记',
    leading: const Icon(MdiIcons.bellBadgeOutline),
    getSubtitle: () => '当前标记样式�?{Pref.msgBadgeMode.desc}',
    onTap: _showMsgBadgeDialog,
  ),
  NormalModel(
    onTap: _showMsgUnReadDialog,
    title: '消息未读类型',
    leading: const Icon(MdiIcons.bellCogOutline),
    getSubtitle: () =>
        '当前消息类型�?{Pref.msgUnReadTypeV2.map((item) => item.title).join('�?)}',
  ),
  NormalModel(
    onTap: _showBarHideTypeDialog,
    title: '�?底栏收起类型',
    leading: const Icon(MdiIcons.arrowExpandVertical),
    getSubtitle: () => '当前�?{Pref.barHideType.label}',
  ),
  SwitchModel(
    title: '首页顶栏收起',
    subtitle: '首页列表滑动时，收起顶栏',
    leading: const Icon(Icons.vertical_align_top_outlined),
    setKey: SettingBoxKey.hideTopBar,
    defaultVal: PlatformUtils.isMobile,
    needReboot: true,
  ),
  SwitchModel(
    title: '首页底栏收起',
    subtitle: '首页列表滑动时，收起底栏',
    leading: const Icon(Icons.vertical_align_bottom_outlined),
    setKey: SettingBoxKey.hideBottomBar,
    defaultVal: PlatformUtils.isMobile,
    needReboot: true,
  ),
  NormalModel(
    onTap: (context, setState) => _showQualityDialog(
      context: context,
      title: '图片质量',
      initValue: Pref.picQuality,
      onChanged: (picQuality) async {
        GlobalData().imgQuality = picQuality;
        await GStorage.setting.put(SettingBoxKey.defaultPicQa, picQuality);
        setState();
      },
    ),
    title: '图片质量',
    subtitle: '选择合适的图片清晰度，上限100%',
    leading: const Icon(Icons.image_outlined),
    getTrailing: (theme) => Text(
      '${Pref.picQuality}%',
      style: theme.textTheme.titleSmall,
    ),
  ),
  NormalModel(
    onTap: (context, setState) => _showQualityDialog(
      context: context,
      title: '查看大图质量',
      initValue: Pref.previewQ,
      onChanged: (picQuality) async {
        await GStorage.setting.put(SettingBoxKey.previewQuality, picQuality);
        setState();
      },
    ),
    title: '查看大图质量',
    subtitle: '选择合适的图片清晰度，上限100%',
    leading: const Icon(Icons.image_outlined),
    getTrailing: (theme) => Text(
      '${Pref.previewQ}%',
      style: theme.textTheme.titleSmall,
    ),
  ),
  NormalModel(
    onTap: _showReduceColorDialog,
    title: '深色下图片颜色叠�?,
    subtitle: '显示颜色=图片原色x所选颜色，大图查看不受影响',
    leading: const Icon(Icons.format_color_fill_outlined),
    getTrailing: (theme) => Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Pref.reduceLuxColor ?? Colors.white,
        shape: BoxShape.circle,
      ),
    ),
  ),
  NormalModel(
    leading: const Icon(Icons.opacity_outlined),
    title: '气泡提示不透明�?,
    subtitle: '自定义气泡提�?Toast)不透明�?,
    getTrailing: (theme) => Text(
      CustomToast.toastOpacity.toStringAsFixed(1),
      style: theme.textTheme.titleSmall,
    ),
    onTap: _showToastDialog,
  ),
  NormalModel(
    onTap: _showThemeTypeDialog,
    leading: const Icon(Icons.flashlight_on_outlined),
    title: '主题模式',
    getSubtitle: () => '当前模式�?{Pref.themeType.desc}',
  ),
  NormalModel(
    leading: const Icon(Icons.home_outlined),
    title: '默认启动�?,
    getSubtitle: () => '当前启动页：${Pref.defaultHomePage.label}',
    onTap: _showDefHomeDialog,
  ),
  const NormalModel(
    title: '滑动动画弹簧参数',
    leading: Icon(Icons.chrome_reader_mode_outlined),
    onTap: _showSpringDialog,
  ),
  NormalModel(
    onTap: (context, setState) async {
      final res = await Get.toNamed('/fontSizeSetting');
      if (res != null) {
        setState();
      }
    },
    title: '字体大小',
    leading: const Icon(Icons.format_size_outlined),
    getSubtitle: () {
      final scale = Pref.defaultTextScale;
      return scale == 1.0 ? '默认' : scale.toString();
    },
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed(
      '/barSetting',
      arguments: {
        'key': SettingBoxKey.tabBarSort,
        'defaultBars': HomeTabType.values,
        'title': '首页标签�?,
      },
    ),
    title: '首页标签�?,
    subtitle: '删除或调换首页标签页',
    leading: const Icon(Icons.toc_outlined),
  ),
  NormalModel(
    onTap: (context, setState) => Get.toNamed(
      '/barSetting',
      arguments: {
        'key': SettingBoxKey.navBarSort,
        'defaultBars': NavigationBarType.values,
        'title': 'Navbar',
      },
    ),
    title: 'Navbar编辑',
    subtitle: '删除或调换Navbar',
    leading: const Icon(Icons.toc_outlined),
  ),
  SwitchModel(
    title: '返回时直接退�?,
    subtitle: '开启后在主页任意tab按返回键都直接退出，关闭则先回到Navbar的第一个tab',
    leading: const Icon(Icons.exit_to_app_outlined),
    setKey: SettingBoxKey.directExitOnBack,
    defaultVal: false,
    onChanged: (value) => Get.find<MainController>().directExitOnBack = value,
  ),
  if (Platform.isAndroid)
    NormalModel(
      onTap: (context, setState) => Get.toNamed('/displayModeSetting'),
      title: '屏幕帧率',
      leading: const Icon(Icons.autofps_select_outlined),
    ),
];

void _showQualityDialog({
  required BuildContext context,
  required String title,
  required int initValue,
  required ValueChanged<int> onChanged,
}) {
  showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      value: initValue.toDouble(),
      title: title,
      min: 10,
      max: 100,
      divisions: 9,
      suffix: '%',
      precise: 0,
    ),
  ).then((result) {
    if (result != null) {
      SmartDialog.showToast('设置成功');
      onChanged(result.toInt());
    }
  });
}

void _showUiScaleDialog(
  BuildContext context,
  VoidCallback setState,
) {
  const minUiScale = 0.5;
  const maxUiScale = 2.0;

  double uiScale = Pref.uiScale;
  final textController = TextEditingController(
    text: uiScale.toStringAsFixed(2),
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('界面缩放'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      content: StatefulBuilder(
        onDispose: textController.dispose,
        builder: (context, setDialogState) => Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              padding: .zero,
              value: uiScale,
              min: minUiScale,
              max: maxUiScale,
              secondaryTrackValue: 1.0,
              divisions: ((maxUiScale - minUiScale) * 20).toInt(),
              label: textController.text,
              onChanged: (value) => setDialogState(() {
                uiScale = value.toPrecision(2);
                textController.text = uiScale.toStringAsFixed(2);
              }),
            ),
            TextFormField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(4),
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]+')),
              ],
              decoration: const InputDecoration(
                labelText: '缩放比例',
                hintText: '0.50 - 2.00',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null &&
                    parsed >= minUiScale &&
                    parsed <= maxUiScale) {
                  setDialogState(() {
                    uiScale = parsed;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            GStorage.setting.delete(SettingBoxKey.uiScale).whenComplete(() {
              setState();
              Get.appUpdate();
              ScaledWidgetsFlutterBinding.instance.scaleFactor = 1.0;
            });
          },
          child: const Text('重置'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '取消',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            GStorage.setting.put(SettingBoxKey.uiScale, uiScale).whenComplete(
              () {
                setState();
                Get.appUpdate();
                ScaledWidgetsFlutterBinding.instance.scaleFactor = uiScale;
              },
            );
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

void _showSpringDialog(BuildContext context, _) {
  final List<String> springDescription = Pref.springDescription
      .map((i) => i.toString())
      .toList(growable: false);
  bool physicalMode = true;

  void physical2Duration() {
    final mass = double.parse(springDescription[0]);
    final stiffness = double.parse(springDescription[1]);
    final damping = double.parse(springDescription[2]);

    final duration = math.sqrt(4 * math.pi * math.pi * mass / stiffness);
    final dampingRatio = damping / (2.0 * math.sqrt(mass * stiffness));
    final bounce = dampingRatio < 1.0
        ? 1.0 - dampingRatio
        : 1.0 / dampingRatio - 1;

    springDescription[0] = duration.toString();
    springDescription[1] = bounce.toString();
  }

  /// from [SpringDescription.withDurationAndBounce] but with higher precision
  void duration2Physical() {
    final duration = double.parse(springDescription[0]);
    final bounce = double.parse(springDescription[1]).clamp(-1.0, 1.0);

    final stiffness = 4 * math.pi * math.pi / math.pow(duration, 2);
    final dampingRatio = bounce > 0 ? 1.0 - bounce : 1.0 / (bounce + 1);
    final damping = 2 * math.sqrt(stiffness) * dampingRatio;

    springDescription[0] = '1';
    springDescription[1] = stiffness.toString();
    springDescription[2] = damping.toString();
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          const Text('弹簧参数'),
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: .compact,
              tapTargetSize: .shrinkWrap,
            ),
            onPressed: () {
              try {
                if (physicalMode) {
                  physical2Duration();
                } else {
                  duration2Physical();
                }
                physicalMode = !physicalMode;
                (context as Element).markNeedsBuild();
              } catch (e) {
                SmartDialog.showToast(e.toString());
              }
            },
            child: Text(physicalMode ? '滑动时间' : '物理参数'),
          ),
        ],
      ),
      content: Column(
        key: ValueKey(physicalMode),
        mainAxisSize: .min,
        children: List.generate(
          physicalMode ? 3 : 2,
          (index) => TextFormField(
            autofocus: index == 0,
            initialValue: springDescription[index],
            keyboardType: .numberWithOptions(
              signed: !physicalMode && index == 1,
              decimal: true,
            ),
            onChanged: (value) => springDescription[index] = value,
            inputFormatters: [
              !physicalMode && index == 1
                  ? FilteringTextInputFormatter.allow(RegExp(r'[-\d\.]+'))
                  : FilteringTextInputFormatter.allow(RegExp(r'[\d\.]+')),
            ],
            decoration: InputDecoration(
              labelText: (physicalMode
                  ? const ['mass', 'stiffness', 'damping']
                  : const ['duration', 'bounce'])[index],
              suffixText: !physicalMode && index == 0 ? 's' : null,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            GStorage.setting.delete(SettingBoxKey.springDescription);
            SmartDialog.showToast('重置成功，重启生�?);
          },
          child: const Text('重置'),
        ),
        TextButton(
          onPressed: Get.back,
          child: Text(
            '取消',
            style: TextStyle(color: ColorScheme.of(context).outline),
          ),
        ),
        TextButton(
          onPressed: () {
            try {
              if (!physicalMode) {
                duration2Physical();
              }
              final res = springDescription.map(double.parse).toList();
              Get.back();
              GStorage.setting.put(SettingBoxKey.springDescription, res);
              SmartDialog.showToast('设置成功，重启生�?);
            } catch (e) {
              SmartDialog.showToast(e.toString());
            }
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

Future<void> _showFontWeightDialog(BuildContext context) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: 'App字体字重',
      value: Pref.appFontWeight.toDouble() + 1,
      min: 1,
      max: FontWeight.values.length.toDouble(),
      divisions: FontWeight.values.length - 1,
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.appFontWeight, res.toInt() - 1);
    Get.forceAppUpdate();
  }
}

Future<void> _showTransitionDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<Transition>(
    context: context,
    builder: (context) => SelectDialog<Transition>(
      title: '页面过渡动画',
      value: Pref.pageTransition,
      values: Transition.values.map((e) => (e, e.name)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.pageTransition, res.index);
    SmartDialog.showToast('重启生效');
    setState();
  }
}

Future<void> _showCardWidthDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<(double, double)>(
    context: context,
    builder: (context) => DualSliderDialog(
      title: '列表最大列宽度（默�?40dp�?,
      value1: Pref.recommendCardWidth,
      value2: Pref.smallCardWidth,
      description1: '主页推荐�?,
      description2: '其他',
      min: 150.0,
      max: 500.0,
      divisions: 35,
      suffix: 'dp',
    ),
  );
  if (res != null) {
    await GStorage.setting.putAll({
      SettingBoxKey.recommendCardWidth: res.$1,
      SettingBoxKey.smallCardWidth: res.$2,
    });
    SmartDialog.showToast('重启生效');
    setState();
  }
}

Future<void> _showUpPosDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<UpPanelPosition>(
    context: context,
    builder: (context) => SelectDialog<UpPanelPosition>(
      title: '动态页UP主显示位�?,
      value: Pref.upPanelPosition,
      values: UpPanelPosition.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.upPanelPosition, res.index);
    SmartDialog.showToast('重启生效');
    setState();
  }
}

Future<void> _showDynBadgeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<DynamicBadgeMode>(
    context: context,
    builder: (context) => SelectDialog<DynamicBadgeMode>(
      title: '动态未读标�?,
      value: Pref.dynamicBadgeType,
      values: DynamicBadgeMode.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    final mainController = Get.find<MainController>()
      ..dynamicBadgeMode = DynamicBadgeMode.values[res.index];
    if (mainController.dynamicBadgeMode != DynamicBadgeMode.hidden) {
      mainController.getUnreadDynamic();
    }
    await GStorage.setting.put(
      SettingBoxKey.dynamicBadgeMode,
      res.index,
    );
    SmartDialog.showToast('设置成功');
    setState();
  }
}

Future<void> _showMsgBadgeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<DynamicBadgeMode>(
    context: context,
    builder: (context) => SelectDialog<DynamicBadgeMode>(
      title: '消息未读标记',
      value: Pref.msgBadgeMode,
      values: DynamicBadgeMode.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    final mainController = Get.find<MainController>()
      ..msgBadgeMode = DynamicBadgeMode.values[res.index];
    if (mainController.msgBadgeMode != DynamicBadgeMode.hidden) {
      mainController.queryUnreadMsg(true);
    } else {
      mainController.msgUnReadCount.value = '';
    }
    await GStorage.setting.put(SettingBoxKey.msgBadgeMode, res.index);
    SmartDialog.showToast('设置成功');
    setState();
  }
}

Future<void> _showMsgUnReadDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<Set<MsgUnReadType>>(
    context: context,
    builder: (context) => MultiSelectDialog<MsgUnReadType>(
      title: '消息未读类型',
      initValues: Pref.msgUnReadTypeV2,
      values: {for (final i in MsgUnReadType.values) i: i.title},
    ),
  );
  if (res != null) {
    final mainController = Get.find<MainController>()..msgUnReadTypes = res;
    if (mainController.msgBadgeMode != DynamicBadgeMode.hidden) {
      mainController.queryUnreadMsg();
    }
    await GStorage.setting.put(
      SettingBoxKey.msgUnReadTypeV2,
      res.map((item) => item.index).toList()..sort(),
    );
    SmartDialog.showToast('设置成功');
    setState();
  }
}

void _showReduceColorDialog(
  BuildContext context,
  VoidCallback setState,
) {
  final reduceLuxColor = Pref.reduceLuxColor;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      clipBehavior: Clip.hardEdge,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      title: const Text('Color Picker'),
      content: SlideColorPicker(
        color: reduceLuxColor ?? Colors.white,
        onChanged: (Color? color) {
          if (color != null && color != reduceLuxColor) {
            if (color == Colors.white) {
              NetworkImgLayer.reduceLuxColor = null;
              GStorage.setting.delete(SettingBoxKey.reduceLuxColor);
              SmartDialog.showToast('设置成功');
              setState();
            } else {
              void onConfirm() {
                NetworkImgLayer.reduceLuxColor = color;
                GStorage.setting.put(
                  SettingBoxKey.reduceLuxColor,
                  color.toARGB32(),
                );
                SmartDialog.showToast('设置成功');
                setState();
              }

              if (color.computeLuminance() < 0.2) {
                showConfirmDialog(
                  context: context,
                  title:
                      '确认使用#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6)}�?,
                  content: '所选颜色过于昏暗，可能会影响图片观�?,
                  onConfirm: onConfirm,
                );
              } else {
                onConfirm();
              }
            }
          }
        },
      ),
    ),
  );
}

Future<void> _showToastDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<double>(
    context: context,
    builder: (context) => SliderDialog(
      title: 'Toast不透明�?,
      value: CustomToast.toastOpacity,
      min: 0.0,
      max: 1.0,
      divisions: 10,
    ),
  );
  if (res != null) {
    CustomToast.toastOpacity = res;
    await GStorage.setting.put(SettingBoxKey.defaultToastOp, res);
    SmartDialog.showToast('设置成功');
    setState();
  }
}

Future<void> _showThemeTypeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<ThemeType>(
    context: context,
    builder: (context) => SelectDialog<ThemeType>(
      title: '主题模式',
      value: Pref.themeType,
      values: ThemeType.values.map((e) => (e, e.desc)).toList(),
    ),
  );
  if (res != null) {
    try {
      Get.find<MineController>().themeType.value = res;
    } catch (_) {}
    GStorage.setting.put(SettingBoxKey.themeMode, res.index);
    Get.changeThemeMode(res.toThemeMode);
    setState();
  }
}

Future<void> _showDefHomeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<NavigationBarType>(
    context: context,
    builder: (context) => SelectDialog<NavigationBarType>(
      title: '首页启动�?,
      value: Pref.defaultHomePage,
      values: NavigationBarType.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.defaultHomePage, res.index);
    SmartDialog.showToast('设置成功，重启生�?);
    setState();
  }
}

Future<void> _showBarHideTypeDialog(
  BuildContext context,
  VoidCallback setState,
) async {
  final res = await showDialog<BarHideType>(
    context: context,
    builder: (context) => SelectDialog<BarHideType>(
      title: '�?底栏收起类型',
      value: Pref.barHideType,
      values: BarHideType.values.map((e) => (e, e.label)).toList(),
    ),
  );
  if (res != null) {
    await GStorage.setting.put(SettingBoxKey.barHideType, res.index);
    SmartDialog.showToast('重启生效');
    setState();
  }
}

NormalModel _useSSDModel() {
  final file = File(path.join(appSupportDirPath, 'use_ssd'));
  void onChanged(BuildContext context, VoidCallback setState) {
    (file.existsSync() ? file.tryDel() : file.create()).whenComplete(() {
      if (context.mounted) {
        setState();
      }
    });
  }

  return NormalModel(
    title: '使用SSD（Server-Side Decoration�?,
    leading: const Icon(Icons.web_asset),
    onTap: onChanged,
    getTrailing: (theme) => Builder(
      builder: (context) => Transform.scale(
        scale: 0.8,
        alignment: .centerRight,
        child: Switch(
          value: file.existsSync(),
          onChanged: (_) =>
              onChanged(context, (context as Element).markNeedsBuild),
        ),
      ),
    ),
  );
}
