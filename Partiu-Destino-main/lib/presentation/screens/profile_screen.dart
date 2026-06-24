import 'package:flutter/material.dart';
import 'company_policies_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../data/app_provider.dart';
import '../../data/models/trip.dart';
import '../../data/models/flight.dart';
import 'hotel_detail_screen.dart';
import 'reservation_summary_screen.dart';
import '../../data/models/reservation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<AppProvider>();
      if (prov.isLoggedIn) {
        prov.fetchFavorites();
        prov.fetchHotels();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final user = prov.user;

    if (!prov.isLoggedIn) {
      return const Center(child: Text('Faça login para ver seu perfil'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        backgroundImage: user?.profileImage != null &&
                                user!.profileImage!.isNotEmpty
                            ? MemoryImage(base64Decode(
                                user.profileImage!.split(',').last))
                            : null,
                        child: (user?.profileImage == null ||
                                user!.profileImage!.isEmpty)
                            ? Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Minha Conta'),
                  _tile(Icons.person_outline, 'Editar Meus Dados',
                      () => Navigator.pushNamed(context, '/edit_profile')),
                  _tile(Icons.favorite_border, 'Destinos Favoritos',
                      () => _showFavoritesDialog(context)),
                  _tile(Icons.history, 'Histórico de Viagens e Reservas',
                      () => _showTripsDialog(context)),
                  _tile(
                      Icons.description_outlined,
                      'Políticas da Empresa (PDF)',
                      () => _showPoliciesPdf(context)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => prov.logout(),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Sair da Conta',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      );

  Widget _tile(IconData icon, String title, VoidCallback onTap) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200)),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right, size: 20),
          onTap: onTap,
        ),
      );

  void _showFavoritesDialog(BuildContext context) {
    final prov = context.read<AppProvider>();
    final favorites =
        prov.hotels.where((h) => prov.favoriteHotelIds.contains(h.id)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Destinos Favoritos'),
        content: SizedBox(
          width: double.maxFinite,
          child: favorites.isEmpty
              ? const Text('Nenhum destino favoritado ainda.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final h = favorites[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: h.imageUrl.startsWith('data:')
                            ? Image.memory(
                                base64Decode(h.imageUrl.split(',').last),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.hotel),
                              )
                            : Image.network(
                                h.imageUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.hotel),
                              ),
                      ),
                      title: Text(h.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(h.location,
                          style: const TextStyle(fontSize: 12)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HotelDetailScreen(hotel: h)));
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'))
        ],
      ),
    );
  }

  void _showPoliciesPdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CompanyPoliciesScreen(),
      ),
    );
  }

  void _showTripsDialog(BuildContext context) {
    final prov = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minhas Viagens'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait<dynamic>([
              prov.getUserTrips(),
              prov.getUserFlightReservations(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final trips = snapshot.data?[0] as List<Trip>? ?? [];
              final flightReservations =
                  snapshot.data?[1] as List<FlightReservation>? ?? [];

              if (trips.isEmpty && flightReservations.isEmpty) {
                return const Text('Nenhuma viagem ou passagem encontrada.');
              }

              return ListView(
                shrinkWrap: true,
                children: [
                  ...trips.map((t) => _tripHistoryCard(context, t)),
                  ...flightReservations
                      .map((r) => _flightReservationHistoryCard(context, r)),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'))
        ],
      ),
    );
  }

  Widget _tripHistoryCard(BuildContext context, Trip t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD),
          child: Icon(Icons.hotel, color: AppColors.primary),
        ),
        title: Text(t.hotelName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo: Hospedagem'),
            Text('Status: ${t.status.toUpperCase()}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (t.status == 'concluida') ...[
              IconButton(
                icon: const Icon(Icons.star_outline,
                    color: Colors.amber, size: 20),
                onPressed: () => _showReviewDialog(context, t),
              ),
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ] else if (t.status == 'pendente' || t.status == 'Confirmada') ...[
              IconButton(
                icon: const Icon(Icons.task_alt,
                    color: AppColors.primary, size: 20),
                tooltip: 'Marcar como Concluída',
                onPressed: () async {
                  final success = await context
                      .read<AppProvider>()
                      .submitReview(t.id, 0, '');
                  if (success && mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Viagem marcada como concluída! Agora você pode avaliá-la.')));
                  }
                },
              ),
            ],
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.pop(context);
          final reservation = Reservation(
            id: t.id,
            hotelId: 0,
            hotelName: t.hotelName,
            hotelImage: '',
            location: '',
            checkinDate: t.travelDate,
            checkoutDate: t.checkoutDate ?? t.travelDate,
            guests: 1,
            totalPrice: t.totalPrice ?? 0.0,
            status: t.status,
          );

          Map<String, dynamic> docs = {};
          try {
            if (t.guestsJson != null) {
              docs = jsonDecode(t.guestsJson!);
            }
          } catch (_) {}

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReservationSummaryScreen(
                reservation: reservation,
                documentsData: docs,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _flightReservationHistoryCard(
      BuildContext context, FlightReservation reservation) {
    final dateText = reservation.departureDate != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(reservation.departureDate!)
        : 'Data a confirmar';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.flight_takeoff, color: Colors.green),
        ),
        title: Text('${reservation.origin ?? ''} → ${reservation.destination ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo: Passagem aérea'),
            Text('Embarque: $dateText'),
            Text('Status: ${reservation.status.toUpperCase()}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pop(context);
          _showFlightReservationDetails(context, reservation);
        },
      ),
    );
  }

  void _showFlightReservationDetails(
      BuildContext context, FlightReservation reservation) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final buyFmt = DateFormat('dd/MM/yyyy HH:mm');
    final departure = reservation.departureDate != null
        ? dateFmt.format(reservation.departureDate!)
        : 'A confirmar';
    final arrival = reservation.arrivalDate != null
        ? dateFmt.format(reservation.arrivalDate!)
        : 'A confirmar';
    final returnText = reservation.returnDate != null
        ? dateFmt.format(reservation.returnDate!)
        : 'Sem volta cadastrada';
    final duration = _formatFlightDuration(
        reservation.departureDate, reservation.arrivalDate);
    final seats = reservation.seats.isNotEmpty
        ? reservation.seats.join(', ')
        : reservation.passengers
            .map((p) => p.seatLabel)
            .where((seat) => seat.isNotEmpty)
            .join(', ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('Detalhes da Passagem Aérea',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flight_takeoff, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tipo de compra: somente passagem aérea',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Origem', reservation.origin ?? 'A confirmar'),
              _detailRow('Destino', reservation.destination ?? 'A confirmar'),
              _detailRow('Embarque ida', departure),
              _detailRow('Desembarque ida', arrival),
              _detailRow('Volta', returnText),
              _detailRow('Tempo de voo', duration),
              _detailRow('Aeronave', reservation.aircraftModel ?? 'A confirmar'),
              _detailRow('Assento(s)', seats.isNotEmpty ? seats : 'A confirmar'),
              _detailRow('Data da compra', buyFmt.format(reservation.createdAt)),
              _detailRow('Valor total',
                  'R\$ ${reservation.totalPrice.toStringAsFixed(2)}'),
              _detailRow('Status', reservation.status.toUpperCase(),
                  color: reservation.status == 'confirmado'
                      ? Colors.green
                      : Colors.orange),
              const SizedBox(height: 20),
              const Text('Passageiros e documentos',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (reservation.passengers.isEmpty)
                const Text('Nenhum passageiro informado.',
                    style: TextStyle(fontSize: 13))
              else
                ...reservation.passengers.map(
                  (p) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${p.documentType}: ${p.documentNumber}',
                            style: const TextStyle(fontSize: 13)),
                        Text('Assento: ${p.seatLabel}',
                            style: const TextStyle(fontSize: 13)),
                        Text('Telefone: ${p.phone}',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Text('Avisos para o embarque',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                '• Levar documento oficial com foto de todos os passageiros.\n'
                '• Chegar com antecedência no aeroporto para check-in e despacho.\n'
                '• Conferir portão de embarque e regras de bagagem.\n'
                '• Animais não são permitidos nas comodidades do avião. Política de tolerância zero.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFlightDuration(DateTime? departure, DateTime? arrival) {
    if (departure == null || arrival == null) return 'A confirmar';
    final difference = arrival.difference(departure);
    if (difference.isNegative) return 'A confirmar';
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}min';
    return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
  }

  void _showReviewDialog(BuildContext context, Trip trip) {
    int selectedRating = 5;
    final reviewCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Avaliar Viagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (i) => IconButton(
                          icon: Icon(
                              i < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber),
                          onPressed: () =>
                              setDialogState(() => selectedRating = i + 1),
                        )),
              ),
              TextField(
                controller: reviewCtrl,
                decoration: const InputDecoration(labelText: 'Seu comentário'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                final success = await context
                    .read<AppProvider>()
                    .submitReview(trip.id, selectedRating, reviewCtrl.text);
                if (success && mounted) {
                  Navigator.pop(ctx);
                  // Atualiza a tela após avaliação
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Avaliação enviada com sucesso!')));
                }
              },
              child: const Text('ENVIAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTripDetails(BuildContext context, Trip trip) {
    final fmt = DateFormat('dd/MM/yyyy');
    Map<String, dynamic>? guests;
    Map<String, dynamic>? policies;
    try {
      if (trip.guestsJson != null) guests = jsonDecode(trip.guestsJson!);
      if (trip.policiesJson != null) policies = jsonDecode(trip.policiesJson!);
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detalhes da Reserva',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              _detailRow('Destino', trip.hotelName),
              _detailRow('Check-in', fmt.format(trip.travelDate)),
              if (trip.checkoutDate != null)
                _detailRow('Check-out', fmt.format(trip.checkoutDate!)),
              _detailRow('Preço Total',
                  'R\$ ${trip.totalPrice?.toStringAsFixed(2) ?? "0.00"}'),
              _detailRow('Status', trip.status.toUpperCase(),
                  color: trip.status == 'concluida'
                      ? Colors.green
                      : Colors.orange),
              const SizedBox(height: 20),
              const Text('Documentos e Participantes',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (guests != null) ...[
                const SizedBox(height: 8),
                Text(
                    'Comprador: ${guests['buyer']['name']} (RG: ${guests['buyer']['rg']})',
                    style: const TextStyle(fontSize: 13)),
                if ((guests['companions'] as List).isNotEmpty)
                  ...(guests['companions'] as List).map((c) => Text(
                      '• ${c['name']} (RG: ${c['rg']})',
                      style: const TextStyle(fontSize: 13))),
              ],
              const SizedBox(height: 20),
              const Text('Políticas Aceitas',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (policies != null)
                ...policies.entries.map((e) => Text('• ${e.key}: ${e.value}',
                    style: const TextStyle(fontSize: 13))),
              const SizedBox(height: 24),
              if (trip.status != 'concluida') ...[
                const Divider(),
                const SizedBox(height: 12),
                const Text('Avalie sua experiência',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (index) => IconButton(
                            icon: Icon(
                                index < (trip.rating ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 32),
                            onPressed: () => _showReviewDialog(context, trip),
                          )),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showReviewDialog(context, trip),
                    child: const Text('Marcar como Concluída e Avaliar'),
                  ),
                ),
              ] else ...[
                const Divider(),
                const SizedBox(height: 12),
                const Text('Sua Avaliação',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                            i < (ratingInt(trip.rating))
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber))),
                if (trip.review != null)
                  Text('"${trip.review}"',
                      style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int ratingInt(dynamic r) {
    if (r == null) return 0;
    if (r is int) return r;
    return (double.tryParse(r.toString()) ?? 0).toInt();
  }

  Widget _detailRow(String label, String value, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textGrey, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color)),
            ),
          ],
        ),
      );
}
