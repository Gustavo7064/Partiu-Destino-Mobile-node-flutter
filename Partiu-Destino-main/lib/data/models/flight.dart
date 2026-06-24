import 'dart:convert';

class Flight {
  final int id;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? arrivalDate;
  final DateTime? returnDate;
  final double pricePerSeat;
  final String aircraftModel;
  final int totalRows;
  final int seatsPerRow;
  final String status;

  Flight({
    required this.id,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.arrivalDate,
    this.returnDate,
    required this.pricePerSeat,
    required this.aircraftModel,
    required this.totalRows,
    required this.seatsPerRow,
    this.status = 'ativo',
  });

  factory Flight.fromJson(Map<String, dynamic> json) => Flight(
        id: json['id'],
        origin: json['origin'],
        destination: json['destination'],
        departureDate: DateTime.parse(json['departure_date']),
        arrivalDate: json['arrival_date'] != null
            ? DateTime.parse(json['arrival_date'])
            : null,
        returnDate: json['return_date'] != null
            ? DateTime.parse(json['return_date'])
            : null,
        pricePerSeat: double.tryParse(json['price_per_seat'].toString()) ?? 0,
        aircraftModel: json['aircraft_model'] ?? 'Boeing 737',
        totalRows: json['total_rows'] ?? 30,
        seatsPerRow: json['seats_per_row'] ?? 6,
        status: json['status'] ?? 'ativo',
      );

  int get totalSeats => totalRows * seatsPerRow;

  String get flightCode {
    String sigla(String value) {
      final clean = value.trim();
      if (clean.length <= 3) return clean.toUpperCase();
      return clean.substring(0, 3).toUpperCase();
    }

    return '${sigla(origin)}-${sigla(destination)}';
  }
}

class Passenger {
  final String name;
  final String cpf;
  final DateTime birthDate;
  final String seatLabel;
  final String documentType;
  final String documentNumber;
  final String phone;

  Passenger({
    required this.name,
    required this.cpf,
    required this.birthDate,
    required this.seatLabel,
    this.documentType = 'CPF',
    String? documentNumber,
    this.phone = '',
  }) : documentNumber = documentNumber ?? cpf;

  Map<String, dynamic> toJson() => {
        'name': name,
        'cpf': cpf,
        'birth_date': birthDate.toIso8601String(),
        'seat_label': seatLabel,
        'document_type': documentType,
        'document_number': documentNumber,
        'phone': phone,
      };

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        name: json['name'] ?? '',
        cpf: json['cpf'] ?? json['document_number'] ?? '',
        birthDate: json['birth_date'] != null
            ? DateTime.parse(json['birth_date'])
            : DateTime.now(),
        seatLabel: json['seat_label'] ?? '',
        documentType: json['document_type'] ?? 'CPF',
        documentNumber: json['document_number'] ?? json['cpf'] ?? '',
        phone: json['phone'] ?? '',
      );
}

class FlightReservation {
  final int id;
  final int flightId;
  final int userId;
  final double totalPrice;
  final List<Passenger> passengers;
  final String status;
  final DateTime createdAt;
  final String? userName;
  final String? userEmail;

  // Snapshot da passagem comprada. Esses campos podem ser editados no admin
  // sem alterar o voo global do catálogo.
  final String? origin;
  final String? destination;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final DateTime? returnDate;
  final String? aircraftModel;
  final List<String> seats;

  FlightReservation({
    required this.id,
    required this.flightId,
    required this.userId,
    required this.totalPrice,
    required this.passengers,
    this.status = 'pendente',
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.origin,
    this.destination,
    this.departureDate,
    this.arrivalDate,
    this.returnDate,
    this.aircraftModel,
    this.seats = const [],
  });

  factory FlightReservation.fromJson(Map<String, dynamic> json) {
    List<Passenger> passengersList = [];
    if (json['passengers_json'] != null) {
      try {
        final decoded = json['passengers_json'] is String
            ? jsonDecode(json['passengers_json'])
            : json['passengers_json'];
        passengersList = (decoded as List)
            .map((p) => Passenger.fromJson(Map<String, dynamic>.from(p)))
            .toList();
      } catch (_) {
        passengersList = [];
      }
    }

    return FlightReservation(
      id: json['id'],
      flightId: json['flight_id'],
      userId: json['user_id'],
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      passengers: passengersList,
      status: json['status'] ?? 'pendente',
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'] ?? json['userName'],
      userEmail: json['user_email'] ?? json['userEmail'],
      origin: json['origin'],
      destination: json['destination'],
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'])
          : null,
      arrivalDate: json['arrival_date'] != null
          ? DateTime.parse(json['arrival_date'])
          : null,
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : null,
      aircraftModel: json['aircraft_model'],
      seats: _parseSeats(json['seats']),
    );
  }

  Map<String, dynamic> toAdminUpdateJson({
    required String adminName,
    required String adminEmail,
    required String reason,
    required String notes,
  }) => {
        'origin': origin,
        'destination': destination,
        'departure_date': departureDate?.toIso8601String(),
        'arrival_date': arrivalDate?.toIso8601String(),
        'return_date': returnDate?.toIso8601String(),
        'aircraft_model': aircraftModel,
        'total_price': totalPrice,
        'passengers_json': jsonEncode(passengers.map((p) => p.toJson()).toList()),
        'seats': seats,
        'status': status,
        'admin_name': adminName,
        'admin_email': adminEmail,
        'reason': reason,
        'notes': notes,
      };

  static List<String> _parseSeats(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return value
        .toString()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

class FlightReservationHistory {
  final int id;
  final int reservationId;
  final String adminName;
  final String adminEmail;
  final String reason;
  final String notes;
  final Map<String, dynamic> oldData;
  final Map<String, dynamic> newData;
  final DateTime createdAt;

  FlightReservationHistory({
    required this.id,
    required this.reservationId,
    required this.adminName,
    required this.adminEmail,
    required this.reason,
    required this.notes,
    required this.oldData,
    required this.newData,
    required this.createdAt,
  });

  factory FlightReservationHistory.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parseMap(dynamic value) {
      if (value == null) return {};
      if (value is Map<String, dynamic>) return value;
      try {
        return Map<String, dynamic>.from(jsonDecode(value.toString()));
      } catch (_) {
        return {};
      }
    }

    return FlightReservationHistory(
      id: json['id'],
      reservationId: json['reservation_id'],
      adminName: json['admin_name'] ?? '',
      adminEmail: json['admin_email'] ?? '',
      reason: json['reason'] ?? '',
      notes: json['notes'] ?? '',
      oldData: parseMap(json['old_data']),
      newData: parseMap(json['new_data']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
