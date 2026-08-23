class BitcoinTrade {
  final double price;
  final int timestampMs;

  const BitcoinTrade({required this.price, required this.timestampMs});

  factory BitcoinTrade.fromJson(Map<String, dynamic> json) => BitcoinTrade(
    price: double.parse(json['p'].toString()),
    timestampMs: json['T'] as int,
  );
}
