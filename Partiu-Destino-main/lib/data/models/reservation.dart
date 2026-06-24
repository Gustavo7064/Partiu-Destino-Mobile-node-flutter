class Reservation {
  final int id;
  final int hotelId;
  final String hotelName;
  final String hotelImage;
  final String location;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final int guests;
  final double totalPrice;
  final String status;

  Reservation({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.hotelImage,
    required this.location,
    required this.checkinDate,
    required this.checkoutDate,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });

  int get nights => checkoutDate.difference(checkinDate).inDays;
}
