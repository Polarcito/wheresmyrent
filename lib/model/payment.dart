class Payment {
  final DateTime date;
  final bool isPaid;
  final String? photoPath; // comprobante [foto]

  Payment({
    required this.date,
    this.isPaid = false,
    this.photoPath,
  });
}
