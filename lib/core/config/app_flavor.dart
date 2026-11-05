/// Flavor build. `dev` untuk API lokal, `prod` untuk rilis (Architecture-M bagian 10).
enum AppFlavor {
  dev,
  prod;

  bool get isProd => this == AppFlavor.prod;
}
