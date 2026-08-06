import '../models/subscription_model.dart';

abstract final class NavigationGuard {
  static bool canEnterApplication(SubscriptionModel? subscription) =>
      subscription?.canAccessApp ?? false;
}
