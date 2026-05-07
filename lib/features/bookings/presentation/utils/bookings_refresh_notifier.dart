import 'package:flutter/foundation.dart';

class BookingsRefreshNotifier {
  BookingsRefreshNotifier._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void notifyUpdated() {
    changes.value++;
  }
}
