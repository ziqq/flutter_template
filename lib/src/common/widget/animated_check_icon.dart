// // autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:rive/rive.dart';
// import 'package:AppOrOrgName/src/common/constants/generated/assets.gen.dart';
// import 'package:AppOrOrgName/src/feature/settings/widget/settings_scope.dart';
// import 'package:ui/ui.dart';

// /// Type of check icon.
// enum CheckIconType {
//   /// Error check icon type.
//   error,

//   /// Success check icon type.
//   success,
// }

// /// {@template animated_check_icon}
// /// AnimatedCheckIcon widget.
// /// This widget displays an animated check or error icon using Rive animations.
// /// {@endtemplate}
// class AnimatedCheckIcon extends StatefulWidget {
//   /// {@macro animated_check_icon}
//   const AnimatedCheckIcon({this.size, this.type, super.key});

//   /// Should be as [CheckIconType.error] or [CheckIconType.success]
//   final CheckIconType? type;

//   /// The size of the icon.
//   final double? size;

//   /// Show processing animation.
//   static void processing(BuildContext context, {String? message}) {
//     final indicator = AnimatedCheckIcon(size: Theme.of(context).uiTheme.size.icon.large);
//     final prefs = SettingsScope.userPreferencesOf(context, listen: false);
//     if (prefs.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
//     EasyLoading.show(indicator: indicator, status: message).ignore();
//   }

//   /// Show error animation.
//   static void succeeded(BuildContext context, {String? message, bool? dismissOnTap}) {
//     final indicator = AnimatedCheckIcon(size: Theme.of(context).uiTheme.size.icon.large, type: CheckIconType.success);
//     final prefs = SettingsScope.userPreferencesOf(context, listen: false);
//     if (prefs.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
//     EasyLoading.show(status: message, indicator: indicator, dismissOnTap: dismissOnTap)
//         .then<void>((_) => Future<void>.delayed(const Duration(seconds: 2)))
//         .then<void>((_) => EasyLoading.dismiss().ignore())
//         .onError((_, _) => EasyLoading.dismiss().ignore())
//         .ignore();
//   }

//   /// Show processing animation.
//   static void error(BuildContext context, {String? message, bool dismissOnTap = true}) {
//     final indicator = AnimatedCheckIcon(size: Theme.of(context).uiTheme.size.icon.large, type: CheckIconType.error);
//     final prefs = SettingsScope.userPreferencesOf(context, listen: false);
//     if (prefs.useHapticFeedback) HapticFeedback.vibrate().ignore();
//     EasyLoading.show(indicator: indicator, dismissOnTap: dismissOnTap, status: message)
//         .then<void>((_) => Future<void>.delayed(const Duration(seconds: 2, milliseconds: 500)))
//         .then<void>((_) => EasyLoading.dismiss().ignore())
//         .onError((_, _) => EasyLoading.dismiss().ignore())
//         .ignore();
//   }

//   /// Dismiss all animations.
//   static void dismiss() => EasyLoading.dismiss().ignore();

//   @override
//   State<AnimatedCheckIcon> createState() => _AnimatedCheckIconSErrortate();
// }

// /// State for widget [AnimatedCheckIcon].
// class _AnimatedCheckIconSErrortate extends State<AnimatedCheckIcon> {
//   late SMITrigger success;
//   late SMITrigger error;
//   late SMITrigger reset;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) => Future<void>.delayed(const Duration(milliseconds: 100)).then<void>((_) => _init()).ignore(),
//     );
//   }

//   @override
//   void didUpdateWidget(covariant AnimatedCheckIcon oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.type != widget.type) _init();
//   }

//   void _init() {
//     switch (widget.type) {
//       case CheckIconType.error:
//         error.fire();
//       case CheckIconType.success:
//         success.fire();
//       default:
//         reset.fire();
//     }
//   }

//   void _onCheckRiveInit(Artboard artboard) {
//     final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
//     artboard.addController(controller!);
//     reset = controller.findInput<bool>('Reset') as SMITrigger;
//     error = controller.findInput<bool>('Error') as SMITrigger;
//     success = controller.findInput<bool>('Check') as SMITrigger;
//   }

//   @override
//   Widget build(BuildContext context) => SizedBox(
//     height: widget.size ?? Theme.of(context).uiTheme.size.icon.large * 1.5,
//     width: widget.size ?? Theme.of(context).uiTheme.size.icon.large * 1.5,
//     child: RepaintBoundary(
//       key: ValueKey<String>('animated_check_icon_${widget.type}'),
//       child: RiveAnimation.asset(
//         Assets.rive.checkError.path, // RiveAssets.check_error,
//         onInit: _onCheckRiveInit,
//         fit: BoxFit.cover,
//       ),
//     ),
//   );
// }
