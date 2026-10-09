enum AuthStateEnum {
  initial,
  registered,
  unRegistered;

  bool get isRegistered => this == registered;
  bool get isUnRegistered => this == unRegistered;
}
