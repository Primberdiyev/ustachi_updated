enum SplashDestination {
  onboarding,
  phoneAuth,
  main,
}

enum TokenInfoEnum {
  initial,
  hasToken,
  hasNotToken;

  bool get isAvaiable => this == hasToken;
  bool get isEmpty => this == hasNotToken;
}
