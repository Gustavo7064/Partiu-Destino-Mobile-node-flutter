import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'models/hotel.dart';
import 'models/user.dart';
import 'models/reservation.dart';
import 'models/trip.dart';
import 'models/flight.dart';
// mock_data.dart removido: o catálogo exibe apenas dados reais do banco de dados.
import 'dart:convert';
import 'dart:developer' as dev;

class CustomRequest {
  final int? id;
  final int userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final bool allowWhatsapp;
  final bool hasChildren;
  final int peopleCount;
  final String reason;
  final String budget;
  final String objectives;
  final String activities;
  final String extraInfo;
  final String interests;
  final String suggestedDestination;
  final String status;
  final DateTime? createdAt;

  CustomRequest({
    this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    required this.allowWhatsapp,
    required this.hasChildren,
    required this.peopleCount,
    required this.reason,
    required this.budget,
    required this.objectives,
    required this.activities,
    required this.extraInfo,
    required this.interests,
    required this.suggestedDestination,
    required this.status,
    this.createdAt,
  });

  factory CustomRequest.fromJson(Map<String, dynamic> json) {
    return CustomRequest(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userPhone: json['user_phone'],
      allowWhatsapp:
          json['allow_whatsapp'] == 1 || json['allow_whatsapp'] == true,
      hasChildren: json['has_children'] == 1 || json['has_children'] == true,
      peopleCount: json['people_count'],
      reason: json['reason'] ?? '',
      budget: json['budget'] ?? '',
      objectives: json['objectives'] ?? '',
      activities: json['activities'] ?? '',
      extraInfo: json['extra_info'] ?? '',
      interests: json['interests'] ?? '',
      suggestedDestination: json['suggested_destination'] ?? '',
      status: json['status'] ?? 'pendente',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class AppProvider extends ChangeNotifier {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  User? _user;
  bool get isLoggedIn => _user != null;
  User? get user => _user;
  bool get isAdmin =>
      _user?.role == 'admin' || _user?.email == 'admin' || _user?.id == 0;

  List<Hotel> _hotels = [];
  List<Hotel> _filteredHotels = [];
  List<Hotel> get hotels =>
      _filteredHotels.isEmpty && _hotels.isNotEmpty ? _hotels : _filteredHotels;

  final List<Reservation> _reservations = [];
  List<Reservation> get reservations => _reservations;

  List<int> _favoriteHotelIds = [];
  List<int> get favoriteHotelIds => _favoriteHotelIds;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        final userData = response.data['user'];
        _user = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
          profileImage: userData['profile_image'],
        );
        notifyListeners();
        await fetchFavorites();
        return {'success': true, 'message': 'Login realizado!'};
      }
      return {'success': false, 'message': response.data['message']};
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {'success': false, 'message': 'Erro inesperado: $e'};
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.data['success']) {
        return {'success': true, 'message': 'Cadastro realizado com sucesso!'};
      }
      return {'success': false, 'message': response.data['message']};
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {'success': false, 'message': 'Erro inesperado: $e'};
    }
  }

  Map<String, dynamic> _handleDioError(DioException e) {
    dev.log('❌ Erro de Conexão: ${e.type}');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return {
        'success': false,
        'message': 'O servidor demorou muito para responder.'
      };
    } else if (e.type == DioExceptionType.connectionError) {
      return {
        'success': false,
        'message': 'Não foi possível conectar ao servidor.'
      };
    } else if (e.response != null) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Erro no servidor'
      };
    }
    return {'success': false, 'message': 'Erro de rede'};
  }

  void logout() {
    _user = null;
    _reservations.clear();
    _favoriteHotelIds.clear();
    notifyListeners();
  }

  Future<void> fetchHotels() async {
    try {
      final response =
          await _dio.get('/hotels').timeout(const Duration(seconds: 10));
      final List<dynamic> data = response.data;
      // Exibe apenas os hotéis cadastrados no banco de dados.
      // Nunca usa dados mockados para não exibir destinos fantasmas.
      _hotels = data.map((h) => Hotel.fromJson(h)).toList();
      _filteredHotels = List.from(_hotels);
      notifyListeners();
    } catch (e) {
      dev.log('Erro ao buscar hotéis: $e');
      // Em caso de erro de conexão, mantém a lista atual sem substituir por mocks.
      // Se ainda não havia dados, mantém lista vazia.
      notifyListeners();
    }
  }

  void applyFilters({String? location, int? minBedrooms, int? minBathrooms}) {
    _filteredHotels = _hotels.where((h) {
      bool matchesLoc = location == null ||
          location.isEmpty ||
          h.location.toLowerCase().contains(location.toLowerCase());
      bool matchesBed = minBedrooms == null || h.bedrooms >= minBedrooms;
      bool matchesBath = minBathrooms == null || h.bathrooms >= minBathrooms;
      return matchesLoc && matchesBed && matchesBath;
    }).toList();
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    if (_user == null || _user!.id == 0) return;
    try {
      final response = await _dio.get('/favorites/${_user!.id}');
      _favoriteHotelIds = List<int>.from(response.data);
      notifyListeners();
    } catch (e) {
      dev.log('Erro ao buscar favoritos: $e');
    }
  }

  Future<void> toggleFavorite(int hotelId) async {
    if (_user == null || _user!.id == 0) return;
    try {
      if (_favoriteHotelIds.contains(hotelId)) {
        await _dio.delete('/favorites/${_user!.id}/$hotelId');
        _favoriteHotelIds.remove(hotelId);
      } else {
        await _dio.post('/favorites',
            data: {'user_id': _user!.id, 'hotel_id': hotelId});
        _favoriteHotelIds.add(hotelId);
      }
      notifyListeners();
    } catch (e) {
      dev.log('Erro ao alternar favorito: $e');
    }
  }

  Future<void> saveTrip({
    required String hotelName,
    required DateTime checkin,
    required DateTime checkout,
    required double totalPrice,
    required String guestsJson,
    required String policiesJson,
    String? roomType,
    int? childrenCount,
  }) async {
    try {
      await _dio.post('/trips', data: {
        'user_id': _user!.id,
        'hotel_name': hotelName,
        'room_type': roomType,
        'children_count': childrenCount,
        'travel_date': checkin.toIso8601String().split('T')[0],
        'checkout_date': checkout.toIso8601String().split('T')[0],
        'total_price': totalPrice,
        'guests_json': guestsJson,
        'policies_json': policiesJson,
      });
    } catch (e) {
      dev.log('Erro ao salvar viagem: $e');
    }
  }

  Future<List<Trip>> getUserTrips() async {
    try {
      if (_user == null) return [];
      final response = await _dio.get('/user/trips/${_user!.id}');
      return (response.data as List).map((t) => Trip.fromJson(t)).toList();
    } catch (e) {
      dev.log('Erro ao buscar viagens: $e');
      return [];
    }
  }

  Future<bool> submitReview(int tripId, int rating, String review) async {
    try {
      final response = await _dio.post('/trips/$tripId/review', data: {
        'rating': rating,
        'review': review,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao enviar avaliação: $e');
      return false;
    }
  }

  // --- ADMIN METHODS (RECONSTRUÍDOS PARA SINCRONIZAR COM ADMIN_SCREEN) ---

  Future<List<User>> getAllUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      return (response.data as List).map((u) => User.fromJson(u)).toList();
    } catch (e) {
      dev.log('Erro ao buscar usuários: $e');
      return [];
    }
  }

  Future<bool> adminUpdateUser(User user, {String? newPassword}) async {
    try {
      final Map<String, dynamic> data = {
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'profile_image': user.profileImage,
      };
      if (newPassword != null && newPassword.isNotEmpty) {
        data['password'] = newPassword;
      }
      final response = await _dio.put('/admin/users/${user.id}', data: data);
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao atualizar usuário: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/admin/users/$id');
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao deletar usuário: $e');
      return false;
    }
  }

  Future<List<Trip>> getAllTrips() async {
    try {
      final response = await _dio.get('/admin/trips');
      return (response.data as List).map((t) => Trip.fromJson(t)).toList();
    } catch (e) {
      dev.log('Erro ao buscar viagens admin: $e');
      return [];
    }
  }

  Future<bool> adminUpdateTrip(Trip trip) async {
    try {
      final response = await _dio.put('/admin/trips/${trip.id}', data: {
        'status': trip.status,
        'total_price': trip.totalPrice,
        'travel_date': trip.travelDate.toIso8601String().split('T')[0],
        'checkout_date': trip.checkoutDate?.toIso8601String().split('T')[0],
      });
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao atualizar viagem: $e');
      return false;
    }
  }

  Future<bool> adminAddHotel(Hotel hotel) async {
    try {
      final response = await _dio.post('/admin/hotels', data: {
        'name': hotel.name,
        'location': hotel.location,
        'description': hotel.description,
        'image_url': hotel.imageUrl,
        'price_per_night': hotel.pricePerNight,
        'amenities': hotel.amenities.join(','),
        'bedrooms': hotel.bedrooms,
        'bathrooms': hotel.bathrooms,
        'tvs': hotel.tvs,
        'has_ac': hotel.hasAC,
        'room_types_json': hotel.roomTypesJson,
      });
      if (response.data['success']) {
        await fetchHotels();
        return true;
      }
    } catch (e) {
      dev.log('Erro ao adicionar hotel: $e');
    }
    return false;
  }

  Future<bool> adminUpdateHotel(Hotel hotel) async {
    try {
      final response = await _dio.put('/admin/hotels/${hotel.id}', data: {
        'name': hotel.name,
        'location': hotel.location,
        'description': hotel.description,
        'image_url': hotel.imageUrl,
        'price_per_night': hotel.pricePerNight,
        'amenities': hotel.amenities.join(','),
        'bedrooms': hotel.bedrooms,
        'bathrooms': hotel.bathrooms,
        'tvs': hotel.tvs,
        'has_ac': hotel.hasAC,
        'room_types_json': hotel.roomTypesJson,
      });
      if (response.data['success']) {
        await fetchHotels();
        return true;
      }
    } catch (e) {
      dev.log('Erro ao atualizar hotel: $e');
    }
    return false;
  }

  Future<bool> deleteHotel(int id) async {
    try {
      final response = await _dio.delete('/admin/hotels/$id');
      if (response.data['success']) {
        await fetchHotels();
        return true;
      }
    } catch (e) {
      dev.log('Erro ao deletar hotel: $e');
    }
    return false;
  }

  Future<List<CustomRequest>> getAdminCustomRequests() async {
    try {
      final response = await _dio.get('/admin/custom-requests');
      return (response.data as List)
          .map((r) => CustomRequest.fromJson(r))
          .toList();
    } catch (e) {
      dev.log('Erro ao buscar pedidos personalizados: $e');
      return [];
    }
  }

  Future<bool> updateCustomRequestStatus(int id, String status) async {
    try {
      final response = await _dio
          .put('/admin/custom-requests/$id/status', data: {'status': status});
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao atualizar status do pedido: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getFinancialData() async {
    try {
      final response = await _dio.get('/admin/financial');
      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      dev.log('Erro ao buscar dados financeiros: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getFlightFinancialData() async {
    try {
      final response = await _dio.get('/admin/flight-financial');
      if (response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      dev.log('Erro ao buscar dados financeiros das passagens: $e');
      return {};
    }
  }

  void addReservation(Reservation reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }

  // --- USER PROFILE ---
  Future<bool> updateUserProfile(String name, String email, String password,
      {String? profileImage}) async {
    if (_user == null) return false;
    try {
      final response = await _dio.put('/user/profile/${_user!.id}', data: {
        'name': name,
        'email': email,
        'password': password.isNotEmpty ? password : null,
        'profile_image': profileImage,
      });
      if (response.data['success']) {
        _user = User(
          id: _user!.id,
          name: name,
          email: email,
          role: _user!.role,
          profileImage: profileImage,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      dev.log('Erro ao atualizar perfil: $e');
      return false;
    }
  }

  // --- CUSTOM REQUESTS ---
  Future<bool> sendCustomRequest({
    required String userName,
    required String userEmail,
    required String userPhone,
    required bool allowWhatsapp,
    required bool hasChildren,
    required int peopleCount,
    required String reason,
    required String budget,
    required String objectives,
    required String activities,
    required String extraInfo,
    required String interests,
    required String suggestedDestination,
  }) async {
    try {
      final response = await _dio.post('/custom-requests', data: {
        'user_id': _user?.id ?? 0,
        'user_name': userName,
        'user_email': userEmail,
        'user_phone': userPhone,
        'allow_whatsapp': allowWhatsapp,
        'has_children': hasChildren,
        'people_count': peopleCount,
        'reason': reason,
        'budget': budget,
        'objectives': objectives,
        'activities': activities,
        'extra_info': extraInfo,
        'interests': interests,
        'suggested_destination': suggestedDestination,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao enviar pedido personalizado: $e');
      return false;
    }
  }

  // --- FLIGHTS (VOOS) ---
  Future<List<Flight>> getFlights() async {
    try {
      final response = await _dio.get('/flights');
      return (response.data as List).map((f) => Flight.fromJson(f)).toList();
    } catch (e) {
      dev.log('Erro ao buscar voos: $e');
      return [];
    }
  }

  Future<Flight?> getFlightDetails(int flightId) async {
    try {
      final response = await _dio.get('/flights/$flightId');
      return Flight.fromJson(response.data);
    } catch (e) {
      dev.log('Erro ao buscar detalhes do voo: $e');
      return null;
    }
  }

  Future<List<String>> getOccupiedSeats(int flightId) async {
    try {
      final response = await _dio.get('/flights/$flightId/occupied-seats');
      return (response.data as List).map((seat) {
        if (seat is Map && seat['seat_label'] != null) {
          return seat['seat_label'].toString();
        }
        return seat.toString();
      }).toList();
    } catch (e) {
      dev.log('Erro ao buscar assentos ocupados: $e');
      return [];
    }
  }

  Future<bool> createFlightReservation(int flightId, double totalPrice, List<Passenger> passengers, List<String> seats) async {
    try {
      final response = await _dio.post('/flight-reservations', data: {
        'flight_id': flightId,
        'user_id': _user?.id ?? 0,
        'total_price': totalPrice,
        'passengers_json': jsonEncode(passengers.map((p) => p.toJson()).toList()),
        'seats': seats,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao criar reserva de voo: $e');
      return false;
    }
  }

  Future<List<FlightReservation>> getUserFlightReservations() async {
    try {
      if (_user == null) return [];
      final response = await _dio.get('/user/flight-reservations/${_user!.id}');
      return (response.data as List).map((r) => FlightReservation.fromJson(r)).toList();
    } catch (e) {
      dev.log('Erro ao buscar reservas de voos: $e');
      return [];
    }
  }

  // --- ADMIN FLIGHTS ---
  Future<List<Flight>> getAdminFlights() async {
    try {
      final response = await _dio.get('/admin/flights');
      return (response.data as List).map((f) => Flight.fromJson(f)).toList();
    } catch (e) {
      dev.log('Erro ao buscar voos admin: $e');
      return [];
    }
  }

  Future<bool> createFlight(String origin, String destination, DateTime departureDate, DateTime? arrivalDate, DateTime? returnDate, double pricePerSeat, String aircraftModel, int totalRows, int seatsPerRow, String status) async {
    try {
      final response = await _dio.post('/admin/flights', data: {
        'origin': origin,
        'destination': destination,
        'departure_date': departureDate.toIso8601String(),
        'arrival_date': arrivalDate?.toIso8601String(),
        'return_date': returnDate?.toIso8601String(),
        'price_per_seat': pricePerSeat,
        'aircraft_model': aircraftModel,
        'total_rows': totalRows,
        'seats_per_row': seatsPerRow,
        'status': status,
      });
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      dev.log('Erro ao criar voo: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('Erro ao criar voo: $e');
      return false;
    }
  }

  Future<bool> updateFlight(int flightId, String origin, String destination, DateTime departureDate, DateTime? arrivalDate, DateTime? returnDate, double pricePerSeat, String aircraftModel, int totalRows, int seatsPerRow, String status) async {
    try {
      final response = await _dio.put('/admin/flights/$flightId', data: {
        'origin': origin,
        'destination': destination,
        'departure_date': departureDate.toIso8601String(),
        'arrival_date': arrivalDate?.toIso8601String(),
        'return_date': returnDate?.toIso8601String(),
        'price_per_seat': pricePerSeat,
        'aircraft_model': aircraftModel,
        'total_rows': totalRows,
        'seats_per_row': seatsPerRow,
        'status': status,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao atualizar voo: $e');
      return false;
    }
  }

  Future<bool> deleteFlight(int flightId) async {
    try {
      final response = await _dio.delete('/admin/flights/$flightId');
      return response.data['success'] ?? false;
    } catch (e) {
      dev.log('Erro ao deletar voo: $e');
      return false;
    }
  }

  Future<List<FlightReservation>> getFlightReservations(int flightId) async {
    try {
      final response = await _dio.get('/admin/flights/$flightId/reservations');
      return (response.data as List).map((r) => FlightReservation.fromJson(r)).toList();
    } catch (e) {
      dev.log('Erro ao buscar reservas do voo: $e');
      return [];
    }
  }

  Future<List<FlightReservation>> getAdminFlightReservations() async {
    try {
      final response = await _dio.get('/admin/flight-reservations');
      return (response.data as List)
          .map((r) => FlightReservation.fromJson(r))
          .toList();
    } catch (e) {
      dev.log('Erro ao buscar passagens compradas: $e');
      return [];
    }
  }

  Future<bool> updateAdminFlightReservation(
    FlightReservation reservation, {
    required String adminName,
    required String adminEmail,
    required String reason,
    required String notes,
  }) async {
    try {
      final response = await _dio.put(
        '/admin/flight-reservations/${reservation.id}',
        data: reservation.toAdminUpdateJson(
          adminName: adminName,
          adminEmail: adminEmail,
          reason: reason,
          notes: notes,
        ),
      );
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      dev.log('Erro ao atualizar passagem: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      dev.log('Erro ao atualizar passagem: $e');
      return false;
    }
  }

  Future<List<FlightReservationHistory>> getFlightReservationHistory(
      int reservationId) async {
    try {
      final response =
          await _dio.get('/admin/flight-reservations/$reservationId/history');
      return (response.data as List)
          .map((h) => FlightReservationHistory.fromJson(h))
          .toList();
    } catch (e) {
      dev.log('Erro ao buscar histórico da passagem: $e');
      return [];
    }
  }

  // --- FILTERS ---
  void filterByLocation(String location) {
    if (location.isEmpty) {
      _filteredHotels = List.from(_hotels);
    } else {
      _filteredHotels = _hotels.where((h) {
        return h.location.toLowerCase().contains(location.toLowerCase()) ||
            h.name.toLowerCase().contains(location.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
