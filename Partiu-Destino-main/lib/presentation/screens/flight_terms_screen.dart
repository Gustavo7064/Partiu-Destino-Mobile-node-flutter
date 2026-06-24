import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/flight.dart';

class FlightTermsScreen extends StatefulWidget {
  final Flight flight;
  final List<Passenger> passengers;
  final List<String> selectedSeats;
  final double totalPrice;
  final VoidCallback onConfirm;

  const FlightTermsScreen({
    super.key,
    required this.flight,
    required this.passengers,
    required this.selectedSeats,
    required this.totalPrice,
    required this.onConfirm,
  });

  @override
  State<FlightTermsScreen> createState() => _FlightTermsScreenState();
}

class _FlightTermsScreenState extends State<FlightTermsScreen> {
  bool _acceptTerms = false;
  bool _acceptDocuments = false;
  bool _acceptBoarding = false;
  bool _acceptSeatPolicy = false;
  bool _acceptPetPolicy = false;
  bool _acceptConduct = false;
  bool _acceptChanges = false;

  bool get _allAccepted =>
      _acceptTerms &&
      _acceptDocuments &&
      _acceptBoarding &&
      _acceptSeatPolicy &&
      _acceptPetPolicy &&
      _acceptConduct &&
      _acceptChanges;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final arrivalText = widget.flight.arrivalDate != null
        ? fmt.format(widget.flight.arrivalDate!)
        : 'A confirmar';
    final returnText = widget.flight.returnDate != null
        ? fmt.format(widget.flight.returnDate!)
        : 'A confirmar';
    final durationText = widget.flight.arrivalDate != null
        ? _formatDuration(widget.flight.arrivalDate!.difference(widget.flight.departureDate))
        : 'A confirmar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Protocolos do Voo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.flight_takeoff, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Resumo da Passagem Aérea',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _summaryLine('Trecho', '${widget.flight.origin} → ${widget.flight.destination}'),
                  _summaryLine('Embarque', fmt.format(widget.flight.departureDate)),
                  _summaryLine('Desembarque', arrivalText),
                  _summaryLine('Volta', returnText),
                  _summaryLine('Tempo de voo', durationText),
                  _summaryLine('Aeronave', widget.flight.aircraftModel),
                  _summaryLine('Passageiros', '${widget.passengers.length}'),
                  _summaryLine('Assentos', widget.selectedSeats.join(', ')),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valor total',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        money.format(widget.totalPrice),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Aceites obrigatórios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _termCheckbox(
              'Termos gerais da passagem aérea',
              'Declaro que li e aceito as regras gerais da reserva de passagem aérea, incluindo conferência de dados, horários, valores e disponibilidade.',
              _acceptTerms,
              (value) => setState(() => _acceptTerms = value ?? false),
            ),
            _termCheckbox(
              'Documentos obrigatórios para embarque',
              'Estou ciente de que todos os passageiros devem apresentar documento oficial com foto e que os dados informados devem estar corretos.',
              _acceptDocuments,
              (value) => setState(() => _acceptDocuments = value ?? false),
            ),
            _termCheckbox(
              'Horário de embarque e comparecimento',
              'Estou ciente de que devo chegar com antecedência ao aeroporto e que atrasos podem impedir o embarque sem garantia de reembolso.',
              _acceptBoarding,
              (value) => setState(() => _acceptBoarding = value ?? false),
            ),
            _termCheckbox(
              'Política de assentos',
              'Entendo que os assentos selecionados serão vinculados à reserva e poderão sofrer alteração somente em situações operacionais excepcionais.',
              _acceptSeatPolicy,
              (value) => setState(() => _acceptSeatPolicy = value ?? false),
            ),
            _termCheckbox(
              'Proibição de animais no avião',
              'Confirmo que estou ciente de que animais não são permitidos nas comodidades do avião nesta reserva.',
              _acceptPetPolicy,
              (value) => setState(() => _acceptPetPolicy = value ?? false),
            ),
            _termCheckbox(
              'Tolerância zero e segurança',
              'Estou ciente de que comportamento inadequado, agressivo ou descumprimento de regras de segurança pode impedir o embarque.',
              _acceptConduct,
              (value) => setState(() => _acceptConduct = value ?? false),
            ),
            _termCheckbox(
              'Alterações e cancelamentos',
              'Entendo que alterações, remarcações ou cancelamentos podem depender de análise, disponibilidade e regras da agência/companhia aérea.',
              _acceptChanges,
              (value) => setState(() => _acceptChanges = value ?? false),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _allAccepted ? widget.onConfirm : null,
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text(
                  'Ir para Pagamento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _summaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _termCheckbox(
    String title,
    String description,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 4),
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalMinutes = duration.inMinutes.abs();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }
}
