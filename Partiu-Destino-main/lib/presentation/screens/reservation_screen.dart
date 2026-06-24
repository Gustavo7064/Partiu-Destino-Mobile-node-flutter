import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../data/app_provider.dart';
import '../../data/models/hotel.dart';
import '../../data/models/reservation.dart';
import 'reservation_summary_screen.dart';
import 'documents_screen.dart';

class ReservationScreen extends StatefulWidget {
  final Hotel hotel;
  const ReservationScreen({super.key, required this.hotel});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime? _checkin;
  DateTime? _checkout;
  int _guests = 1;
  int _childrenUnder12 = 0;
  String? _selectedRoomType;
  double _roomMultiplier = 1.0;
  final _fmt = DateFormat('dd/MM/yyyy');

  int get _nights {
    if (_checkin == null || _checkout == null) return 0;
    return _checkout!.difference(_checkin!).inDays;
  }

  double get _total {
    if (_nights < 1) return 0;
    double basePrice = widget.hotel.pricePerNight * _roomMultiplier;
    double adultPrice = _guests * basePrice;
    double childPrice = _childrenUnder12 * (basePrice * 0.6); // 40% de desconto
    return _nights * (adultPrice + childPrice);
  }

  Future<void> _pickDate(bool isCheckin) async {
    final now = DateTime.now();
    final first =
        isCheckin ? now : (_checkin ?? now).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isCheckin) {
          _checkin = picked;
          if (_checkout != null && !_checkout!.isAfter(picked)) {
            _checkout = null;
          }
        } else {
          _checkout = picked;
        }
      });
    }
  }

  void _confirmar() async {
    if (_checkin == null || _checkout == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione as datas')),
      );
      return;
    }
    if (_nights < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out deve ser após o check-in')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentsScreen(
          hotelName: widget.hotel.name,
          guests: _guests,
          totalPrice: _total, // Passando o total calculado
          onConfirm: (documentsData) async {
            final prov = context.read<AppProvider>();
            
    await prov.saveTrip(
      hotelName: widget.hotel.name, 
      checkin: _checkin!, 
      checkout: _checkout!,
      totalPrice: _total,
      roomType: _selectedRoomType ?? 'Padrão',
      childrenCount: _childrenUnder12,
      guestsJson: jsonEncode(documentsData),
      policiesJson: jsonEncode({
        'pets': 'Proibido',
        'noise': 'Multa RS 200',
        'cleaning': 'Taxa RS 150',
        'age': 'Mínimo 18 anos'
      }),
    );

            final reservation = Reservation(
              id: DateTime.now().millisecondsSinceEpoch,
              hotelId: widget.hotel.id,
              hotelName: widget.hotel.name,
              hotelImage: widget.hotel.imageUrl,
              location: widget.hotel.location,
              checkinDate: _checkin!,
              checkoutDate: _checkout!,
              guests: _guests,
              totalPrice: _total,
              status: 'Confirmada',
            );

            prov.addReservation(reservation);

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ReservationSummaryScreen(
                  reservation: reservation,
                  documentsData: documentsData,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fazer Reserva'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.hotel.imageUrl.startsWith('data:')
                        ? Image.memory(
                            base64Decode(
                                widget.hotel.imageUrl.split(',').last),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: AppColors.border,
                              child: const Icon(Icons.hotel,
                                  color: AppColors.textGrey),
                            ),
                          )
                        : Image.network(
                            widget.hotel.imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: AppColors.border,
                              child: const Icon(Icons.hotel,
                                  color: AppColors.textGrey),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hotel.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            )),
                        const SizedBox(height: 4),
                        Text(widget.hotel.location,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${widget.hotel.pricePerNight.toStringAsFixed(0)}/noite',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Datas',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateTile(
                    'Check-in',
                    _checkin != null ? _fmt.format(_checkin!) : 'Selecionar',
                    Icons.login_rounded,
                    () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTile(
                    'Check-out',
                    _checkout != null ? _fmt.format(_checkout!) : 'Selecionar',
                    Icons.logout_rounded,
                    () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Hóspedes',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 12),
            _buildGuestSelector(
              title: 'Adultos (ou acima de 12 anos)',
              subtitle: 'Preço integral',
              count: _guests,
              onChanged: (val) => setState(() => _guests = val),
              min: 1,
            ),
            const SizedBox(height: 12),
            _buildGuestSelector(
              title: 'Crianças (menores de 12 anos)',
              subtitle: '40% de desconto aplicado',
              count: _childrenUnder12,
              onChanged: (val) => setState(() => _childrenUnder12 = val),
              min: 0,
            ),
            const SizedBox(height: 24),
            const Text('Tipo de Acomodação',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 12),
            // Lista de Quartos com Destaque Visual
            ...widget.hotel.roomTypes.map((room) {
              final bool isSelected = _selectedRoomType == room.name;
              final bool isLuxo = room.name.toLowerCase().contains('luxo') || room.priceMultiplier > 1.2;
              
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedRoomType = room.name;
                  _roomMultiplier = room.priceMultiplier;
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLuxo ? Icons.king_bed : Icons.bed,
                        color: isSelected ? AppColors.primary : AppColors.textGrey,
                        size: 30,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (isLuxo) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('MELHOR ESCOLHA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(room.description, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                            if (room.priceMultiplier > 1.0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '+ ${( (room.priceMultiplier - 1) * 100 ).toStringAsFixed(0)}% no valor da diária',
                                  style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: room.name,
                        groupValue: _selectedRoomType,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() {
                          _selectedRoomType = val;
                          _roomMultiplier = room.priceMultiplier;
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            if (widget.hotel.roomTypes.isEmpty)
              _buildDefaultRoomTile(),
            const SizedBox(height: 24),
            if (_nights > 0) ...[
              const Text('Resumo',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _sumRow('Adultos', '$_guests x R\$ ${widget.hotel.pricePerNight.toStringAsFixed(0)}'),
                    if (_childrenUnder12 > 0)
                      _sumRow('Crianças (<12 anos)', '$_childrenUnder12 x R\$ ${(widget.hotel.pricePerNight * 0.6).toStringAsFixed(0)}'),
                    _sumRow('Noites', '$_nights'),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        Text(
                          'R\$ ${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Confirmar Reserva',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(
          String label, String value, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildDefaultRoomTile() {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRoomType = 'Padrão';
        _roomMultiplier = 1.0;
      }),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (_selectedRoomType == 'Padrão' || _selectedRoomType == null) ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (_selectedRoomType == 'Padrão' || _selectedRoomType == null) ? AppColors.primary : AppColors.border,
            width: (_selectedRoomType == 'Padrão' || _selectedRoomType == null) ? 2 : 1,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.bed, color: AppColors.primary, size: 30),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quarto Padrão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Acomodação simples e confortável.', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelector({
    required String title,
    required String subtitle,
    required int count,
    required Function(int) onChanged,
    required int min,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                onPressed: count > min ? () => onChanged(count - 1) : null,
              ),
              Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style:
                    const TextStyle(color: AppColors.textGrey, fontSize: 13)),
            Text(v,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
}
