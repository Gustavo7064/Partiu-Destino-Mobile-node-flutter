class Trip {
  final int id;
  final int userId;
  final String hotelName;
  final DateTime travelDate;
  final DateTime? checkoutDate;
  final String? notes;
  final String? userName;
  final double? totalPrice;
  final String? guestsJson;
  final String? policiesJson;
  final String status;
  final int? rating;
  final String? review;

  Trip({
    required this.id,
    required this.userId,
    required this.hotelName,
    required this.travelDate,
    this.checkoutDate,
    this.notes,
    this.userName,
    this.totalPrice,
    this.guestsJson,
    this.policiesJson,
    this.status = 'pendente',
    this.rating,
    this.review,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'],
        userId: json['user_id'],
        hotelName: json['hotel_name'],
        travelDate: DateTime.parse(json['travel_date']),
        checkoutDate: json['checkout_date'] != null ? DateTime.parse(json['checkout_date']) : null,
        notes: json['notes'],
        userName: json['userName'],
        totalPrice: json['total_price'] != null ? double.tryParse(json['total_price'].toString()) : null,
        guestsJson: json['guests_json'],
        policiesJson: json['policies_json'],
        status: json['status'] ?? 'pendente',
        rating: json['rating'],
        review: json['review'],
      );
}
