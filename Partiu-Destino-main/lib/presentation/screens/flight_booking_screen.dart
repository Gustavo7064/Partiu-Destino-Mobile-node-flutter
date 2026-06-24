import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/app_provider.dart';
import '../../data/models/flight.dart';
import '../../core/constants/app_colors.dart';
import 'flight_terms_screen.dart';
import 'payment_screen.dart';

class FlightBookingScreen extends StatefulWidget {
  final Flight flight;

  const FlightBookingScreen({super.key, required this.flight});

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  int _passengerCount = 1;
  final List<String> _selectedSeats = [];
  final List<_PassengerFormData> _passengers = [];
  Set<String> _occupiedSeats = {};
  bool _isLoadingSeats = true;
  bool _acceptedWarnings = false;

  @override
  void initState() {
    super.initState();
    _loadOccupiedSeats();
  }

  @override
  void dispose() {
    for (final passenger in _passengers) {
      passenger.dispose();
    }
    super.dispose();
  }

  Future<void> _loadOccupiedSeats() async {
    final prov = context.read<AppProvider>();
    final occupied = await prov.getOccupiedSeats(widget.flight.id);
    if (!mounted) return;
    setState(() {
      _occupiedSeats = Set.from(occupied);
      _isLoadingSeats = false;
    });
  }

  String _generateSeatLabel(int row, int col) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return '${row + 1}${letters[col % letters.length]}';
  }

  void _changePassengerCount(int value) {
    setState(() {
      _passengerCount = value;
      while (_selectedSeats.length > _passengerCount) {
        final removedSeat = _selectedSeats.removeLast();
        final index = _passengers.indexWhere((p) => p.seatLabel == removedSeat);
        if (index >= 0) {
          _passengers[index].dispose();
          _passengers.removeAt(index);
        }
      }
    });
  }

  void _toggleSeat(String seat) {
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
        final index = _passengers.indexWhere((p) => p.seatLabel == seat);
        if (index >= 0) {
          _passengers[index].dispose();
          _passengers.removeAt(index);
        }
      } else if (_selectedSeats.length < _passengerCount) {
        _selectedSeats.add(seat);
        _passengers.add(_PassengerFormData(seatLabel: seat));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Você selecionou o limite de $_passengerCount passagem(ns).',
            ),
          ),
        );
      }
    });
  }

  Future<void> _pickBirthDate(_PassengerFormData passenger) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: passenger.birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selectedDate != null) {
      setState(() => passenger.birthDate = selectedDate);
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedSeats.length != _passengerCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione $_passengerCount assento(s).')),
      );
      return;
    }

    if (!_acceptedWarnings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirme que leu os avisos e regras do voo.'),
        ),
      );
      return;
    }

    final hasInvalidPassenger = _passengers.any((p) =>
        p.nameController.text.trim().isEmpty ||
        p.documentController.text.trim().isEmpty ||
        p.phoneController.text.trim().isEmpty);

    if (hasInvalidPassenger) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha nome, documento e telefone de todos os passageiros.'),
        ),
      );
      return;
    }

    final totalPrice = widget.flight.pricePerSeat * _passengerCount;
    final prov = context.read<AppProvider>();

    final passengers = _passengers
        .map((p) => Passenger(
              name: p.nameController.text.trim(),
              cpf: p.documentController.text.trim(),
              birthDate: p.birthDate,
              seatLabel: p.seatLabel,
              documentType: p.documentType,
              documentNumber: p.documentController.text.trim(),
              phone: p.phoneController.text.trim(),
            ))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlightTermsScreen(
          flight: widget.flight,
          passengers: passengers,
          selectedSeats: List<String>.from(_selectedSeats),
          totalPrice: totalPrice,
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (paymentContext) => PaymentScreen(
                  itemName: 'Passagem ${widget.flight.origin} → ${widget.flight.destination}',
                  amount: totalPrice,
                  userEmail: prov.user?.email ?? '',
                  userName: prov.user?.name ?? passengers.first.name,
                  onPaymentSuccess: () async {
                    final success = await prov.createFlightReservation(
                      widget.flight.id,
                      totalPrice,
                      passengers,
                      _selectedSeats,
                    );

                    if (!paymentContext.mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(paymentContext).showSnackBar(
                        const SnackBar(
                          content: Text('Pagamento confirmado e passagem salva em Minhas Viagens!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(paymentContext).popUntil((route) => route.isFirst);
                    } else {
                      ScaffoldMessenger.of(paymentContext).showSnackBar(
                        const SnackBar(
                          content: Text('Pagamento confirmado, mas não foi possível salvar a passagem. Tente novamente.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
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
        title: const Text('Reserva de Passagens'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightInfo(),
            const SizedBox(height: 20),
            _buildPassengerCountSelector(),
            const SizedBox(height: 20),
            _buildWarningsSection(),
            const SizedBox(height: 20),
            _buildSeatMap(),
            const SizedBox(height: 20),
            _buildPassengerForm(),
            const SizedBox(height: 24),
            _buildBookingButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo() {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final arrivalText = widget.flight.arrivalDate != null
        ? fmt.format(widget.flight.arrivalDate!)
        : 'A confirmar';
    final returnText = widget.flight.returnDate != null
        ? fmt.format(widget.flight.returnDate!)
        : 'A confirmar';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flight_takeoff, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.flight.flightCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${widget.flight.origin} → ${widget.flight.destination}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailLine(Icons.calendar_month, 'Ida', fmt.format(widget.flight.departureDate)),
          const SizedBox(height: 8),
          _detailLine(Icons.flight_land, 'Chegada ida', arrivalText),
          const SizedBox(height: 8),
          _detailLine(Icons.keyboard_return, 'Volta', returnText),
          const SizedBox(height: 8),
          _detailLine(Icons.airplanemode_active, 'Aeronave', widget.flight.aircraftModel),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valor por passagem',
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              Text(
                'R\$ ${widget.flight.pricePerSeat.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailLine(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
        ],
      );

  Widget _buildPassengerCountSelector() {
    return _sectionCard(
      title: 'Quantidade de passagens',
      icon: Icons.confirmation_number_outlined,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
            onPressed: _passengerCount > 1
                ? () => _changePassengerCount(_passengerCount - 1)
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_passengerCount',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
            onPressed: _passengerCount < widget.flight.totalSeats
                ? () => _changePassengerCount(_passengerCount + 1)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Depois escolha $_passengerCount assento(s) no mapa do avião.',
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsSection() {
    return _sectionCard(
      title: 'Avisos e regras do voo',
      icon: Icons.warning_amber_rounded,
      borderColor: Colors.orange.withValues(alpha: 0.35),
      backgroundColor: Colors.orange.withValues(alpha: 0.08),
      child: Column(
        children: [
          _warningItem(
            Icons.pets,
            'Animais proibidos',
            'Não é permitido levar animais nas comodidades do avião durante esta reserva.',
          ),
          const SizedBox(height: 10),
          _warningItem(
            Icons.block,
            'Política de tolerância zero',
            'A companhia poderá impedir o embarque em caso de descumprimento das regras de segurança.',
          ),
          const SizedBox(height: 10),
          _warningItem(
            Icons.badge_outlined,
            'Documentos obrigatórios',
            'Informe CPF ou passaporte, data de nascimento e telefone dos passageiros.',
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _acceptedWarnings,
            activeColor: AppColors.primary,
            onChanged: (value) => setState(() => _acceptedWarnings = value ?? false),
            title: const Text(
              'Li e estou ciente dos avisos e regras da passagem aérea.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _warningItem(IconData icon, String title, String description) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildSeatMap() {
    if (_isLoadingSeats) {
      return const Center(child: CircularProgressIndicator());
    }

    return _sectionCard(
      title: 'Escolha onde deseja sentar',
      icon: Icons.event_seat_outlined,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text(
                'Frente do avião',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Column(
            children: List.generate(widget.flight.totalRows, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.flight.seatsPerRow, (col) {
                    final seat = _generateSeatLabel(row, col);
                    final isOccupied = _occupiedSeats.contains(seat);
                    final isSelected = _selectedSeats.contains(seat);
                    final needsAisle = widget.flight.seatsPerRow >= 4 &&
                        col == (widget.flight.seatsPerRow ~/ 2);

                    return Row(
                      children: [
                        if (needsAisle) const SizedBox(width: 18),
                        GestureDetector(
                          onTap: !isOccupied ? () => _toggleSeat(seat) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isOccupied
                                  ? Colors.grey.shade300
                                  : isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                              border: Border.all(
                                color: isOccupied
                                    ? Colors.grey
                                    : isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                seat,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : isOccupied
                                          ? Colors.grey.shade700
                                          : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem(Colors.white, 'Disponível'),
              _buildLegendItem(AppColors.primary, 'Selecionado'),
              _buildLegendItem(Colors.grey.shade300, 'Ocupado'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPassengerForm() {
    return _sectionCard(
      title: 'Documentos dos passageiros',
      icon: Icons.assignment_ind_outlined,
      child: _passengers.isEmpty
          ? const Text(
              'Selecione os assentos para abrir os campos de documentos.',
              style: TextStyle(color: AppColors.textGrey),
            )
          : Column(
              children: _passengers.asMap().entries.map((entry) {
                return _buildPassengerCard(entry.key, entry.value);
              }).toList(),
            ),
    );
  }

  Widget _buildPassengerCard(int index, _PassengerFormData passenger) {
    final birthFmt = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passageiro ${index + 1} • Assento ${passenger.seatLabel}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passenger.nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration('Nome completo', Icons.person_outline),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: passenger.documentType,
            decoration: _inputDecoration('Tipo de documento', Icons.badge_outlined),
            items: const [
              DropdownMenuItem(value: 'CPF', child: Text('CPF')),
              DropdownMenuItem(value: 'Passaporte', child: Text('Passaporte')),
              DropdownMenuItem(value: 'RG', child: Text('RG')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => passenger.documentType = value);
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passenger.documentController,
            keyboardType: TextInputType.text,
            decoration: _inputDecoration(
              'Número do documento',
              Icons.credit_card_outlined,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickBirthDate(passenger),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      'Data de nascimento',
                      Icons.cake_outlined,
                    ),
                    child: Text(birthFmt.format(passenger.birthDate)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: passenger.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Telefone', Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  Widget _buildBookingButton() {
    final total = widget.flight.pricePerSeat * _passengerCount;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmBooking,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          'Avançar para Protocolos - R\$ ${total.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PassengerFormData {
  final String seatLabel;
  String documentType = 'CPF';
  DateTime birthDate = DateTime(2000, 1, 1);
  final TextEditingController nameController = TextEditingController();
  final TextEditingController documentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  _PassengerFormData({required this.seatLabel});

  void dispose() {
    nameController.dispose();
    documentController.dispose();
    phoneController.dispose();
  }
}
