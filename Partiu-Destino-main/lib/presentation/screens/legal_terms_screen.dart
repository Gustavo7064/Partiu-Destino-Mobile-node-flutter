import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class LegalTermsScreen extends StatefulWidget {
  final String hotelName;
  final int guests;
  final List<Map<String, dynamic>> companions;
  final Function() onConfirm;

  const LegalTermsScreen({
    super.key,
    required this.hotelName,
    required this.guests,
    required this.companions,
    required this.onConfirm,
  });

  @override
  State<LegalTermsScreen> createState() => _LegalTermsScreenState();
}

class _LegalTermsScreenState extends State<LegalTermsScreen> {
  bool _acceptTerms = false;
  bool _acceptAgeRestriction = false;
  bool _acceptNoiseFines = false;
  bool _acceptCleaningFines = false;
  bool _acceptPetPolicy = false;
  bool _hasMinor = false;
  String? _minorWarning;

  @override
  void initState() {
    super.initState();
    _checkForMinors();
  }

  void _checkForMinors() {
    for (var companion in widget.companions) {
      final birthDate = companion['birthDate'] as String?;
      if (birthDate != null && birthDate.isNotEmpty) {
        try {
          final fmt = DateFormat('dd/MM/yyyy');
          final date = fmt.parse(birthDate);
          final age = DateTime.now().difference(date).inDays ~/ 365;
          if (age < 18) {
            setState(() {
              _hasMinor = true;
              _minorWarning = 'Detectamos que um dos acompanhantes é menor de 18 anos. Ele/ela DEVE estar acompanhado(a) de um responsável legal presente na acomodação.';
            });
            return;
          }
        } catch (_) {}
      }
    }
  }

  bool _allTermsAccepted() {
    return _acceptTerms &&
        _acceptAgeRestriction &&
        _acceptNoiseFines &&
        _acceptCleaningFines &&
        _acceptPetPolicy &&
        (!_hasMinor || _acceptAgeRestriction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Termos e Avisos Legais'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasMinor)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _minorWarning ?? '',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Termos e Condições',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _termCheckbox(
              'Aceito os Termos e Condições Gerais',
              'Declaro que li e concordo com todos os termos e condições da acomodação.',
              _acceptTerms,
              (value) => setState(() => _acceptTerms = value ?? false),
            ),
            const SizedBox(height: 16),
            _termCheckbox(
              'Restrição de Maioridade',
              'Confirmo que tenho 18 anos ou mais. Se sou menor de idade, estou ciente que minha reserva pode ser cancelada e que devo estar acompanhado(a) de responsável legal. Cartas ou e-mails de responsáveis NÃO serão aceitos como comprovação.',
              _acceptAgeRestriction,
              (value) => setState(() => _acceptAgeRestriction = value ?? false),
            ),
            const SizedBox(height: 16),
            _termCheckbox(
              'Política de Ruído e Multas',
              'Entendo que ruídos excessivos entre 22h e 8h resultarão em multa de R\$ 200. Sou responsável por manter silêncio durante os horários restritos.',
              _acceptNoiseFines,
              (value) => setState(() => _acceptNoiseFines = value ?? false),
            ),
            const SizedBox(height: 16),
            _termCheckbox(
              'Taxa de Limpeza e Danos',
              'Concordo que acomodações sujas ou danificadas resultarão em taxa de limpeza de R\$ 150 ou mais, conforme avaliação da administração.',
              _acceptCleaningFines,
              (value) => setState(() => _acceptCleaningFines = value ?? false),
            ),
            const SizedBox(height: 16),
            _termCheckbox(
              'Política de Animais de Estimação',
              'Confirmo que NÃO trarei animais de estimação ou animais exóticos para a acomodação. Violações resultarão em expulsão imediata sem reembolso.',
              _acceptPetPolicy,
              (value) => setState(() => _acceptPetPolicy = value ?? false),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _allTermsAccepted() ? widget.onConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmar Reserva',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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

  Widget _termCheckbox(
    String title,
    String description,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: value ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
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
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 8),
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
}
