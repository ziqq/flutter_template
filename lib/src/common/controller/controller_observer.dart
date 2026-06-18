import 'package:control/control.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:l/l.dart';

/// Observer for [Controller], react to changes in any controller.
final class ControllerObserver implements IControllerObserver {
  const ControllerObserver();

  @override
  void onCreate(Controller controller) {
    l.v6(
      '${controller is StateController ? 'StateController' : 'Controller'} | '
      '${controller.name}.new',
    );
  }

  @override
  void onDispose(Controller controller) {
    l.v5(
      '${controller is StateController ? 'StateController' : 'Controller'} | '
      '${controller.name}.dispose',
    );
  }

  @override
  void onHandler(HandlerContext context) {
    final stopwatch = Stopwatch()..start();
    l.v6(
      '${context.controller is StateController ? 'StateController' : 'Controller'} | '
      '${context.controller.name}.${context.name}',
      context.meta,
    );
    context.done.whenComplete(() {
      stopwatch.stop();
      l.d(
        '${context.controller is StateController ? 'StateController' : 'Controller'} | '
        '${context.controller.name}.${context.name} | '
        'duration: ${stopwatch.elapsed}',
        context.meta,
      );
    });
  }

  @override
  void onStateChanged<S extends Object>(StateController<S> controller, S prevState, S nextState) {
    final context = Controller.context;
    if (context == null) {
      // State change occurred outside of the handler
      l.d(
        'StateController | '
        '${controller.name} | '
        '$prevState -> $nextState',
      );
    } else {
      // State change occurred inside the handler
      l.d(
        'StateController | '
        '${controller.name}.${context.name} | '
        '$prevState -> $nextState',
        context.meta,
      );
    }
  }

  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    final context = Controller.context;
    ErrorUtil.logError(error, stackTrace, hints: context?.meta).ignore();
    if (context == null) {
      // Error occurred outside of the handler
      l.w(
        '${controller is StateController ? 'StateController' : 'Controller'} | '
        '${controller.name} | '
        '$error',
        stackTrace,
      );
    } else {
      // Error occurred inside the handler
      l.w(
        '${controller is StateController ? 'StateController' : 'Controller'} | '
        '${controller.name}.${context.name} | '
        '$error',
        stackTrace,
        context.meta,
      );
    }
  }
}

// Example of any event
// Future<void> event({
//   Map<String, Object?>? meta,
//   void Function(HandlerContext context)? out,
// }) =>
//     handle(
//       () async {
//         final stopwatch = Stopwatch()..start();
//         try {
//           setState(false);
//           await Future<void>.delayed(Duration.zero);
//           out?.call(Controller.context!);
//           setState(true);
//           Controller.context?.meta['duration'] = stopwatch.elapsed;
//         } finally {
//           stopwatch.stop();
//         }
//       },
//       name: 'event',
//       meta: {
//         ...?meta,
//         'started_at': DateTime.now(),
//       },
//     );
