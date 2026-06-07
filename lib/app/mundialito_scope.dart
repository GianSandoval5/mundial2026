import 'package:flutter/widgets.dart';

import '../features/mundial/presentation/mundialito_controller.dart';

class MundialitoScope extends InheritedNotifier<MundialitoController> {
  const MundialitoScope({
    required MundialitoController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static MundialitoController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<MundialitoScope>();
    assert(scope != null, 'MundialitoScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
