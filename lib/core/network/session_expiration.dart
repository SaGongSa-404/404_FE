abstract final class SessionExpiration {
  static void Function()? onExpired;

  static void notify() => onExpired?.call();
}
