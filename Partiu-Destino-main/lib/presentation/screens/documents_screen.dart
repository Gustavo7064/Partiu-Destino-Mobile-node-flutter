import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'legal_terms_screen.dart';
import 'payment_screen.dart';

class DocumentsScreen extends StatefulWidget {
  final String hotelName;
  final int guests;
  final double totalPrice; // Adicionado valor total
  final Function(Map<String, dynamic>) onConfirm;

  const DocumentsScreen({
    super.key,
    required this.hotelName,
    required this.guests,
    required this.totalPrice,
    required this.onConfirm,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Controladores para o comprador (hóspede principal)
  final _buyerNameCtrl = TextEditingController();
  final _buyerRgCtrl = TextEditingController();
  final _buyerCpfCtrl = TextEditingController();
  final _buyerEmailCtrl = TextEditingController();

  // Listas para acompanhantes
  late List<Map<String, TextEditingController>> _companionsControllers;

  @override
  void initState() {
    super.initState();
    _initializeCompanionsControllers();
  }

  void _initializeCompanionsControllers() {
    _companionsControllers = [];
    // O widget.guests já inclui o total de pessoas (adultos + crianças)
    // Subtraímos 1 pois o comprador já é o primeiro adulto.
    for (int i = 0; i < widget.guests - 1; i++) {
      _companionsControllers.add({
        'name': TextEditingController(),
        'rg': TextEditingController(),
        'cpf': TextEditingController(),
        'birthDate': TextEditingController(),
        'relationship': TextEditingController(),
        'isChild':
            TextEditingController(text: 'false'), // Para controle interno
      });
    }
  }

  @override
  void dispose() {
    _buyerNameCtrl.dispose();
    _buyerRgCtrl.dispose();
    _buyerCpfCtrl.dispose();
    _buyerEmailCtrl.dispose();
    for (var companion in _companionsControllers) {
      companion.forEach((_, controller) => controller.dispose());
    }
    super.dispose();
  }

  bool _validateFields() {
    if (_buyerNameCtrl.text.isEmpty ||
        _buyerRgCtrl.text.isEmpty ||
        _buyerCpfCtrl.text.isEmpty ||
        _buyerEmailCtrl.text.isEmpty) {
      _showError('Preencha todos os dados do comprador');
      return false;
    }

    // Validar email
    if (!_buyerEmailCtrl.text.contains('@')) {
      _showError('E-mail inválido');
      return false;
    }

    // Validar acompanhantes
    for (int i = 0; i < _companionsControllers.length; i++) {
      final companion = _companionsControllers[i];
      if (companion['name']!.text.isEmpty ||
          companion['rg']!.text.isEmpty ||
          companion['cpf']!.text.isEmpty ||
          companion['birthDate']!.text.isEmpty ||
          companion['relationship']!.text.isEmpty) {
        _showError('Preencha todos os dados do acompanhante ${i + 1}');
        return false;
      }
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _confirmar() {
    if (!_validateFields()) return;

    final companions = _companionsControllers
        .map((companion) => {
              'name': companion['name']!.text,
              'rg': companion['rg']!.text,
              'cpf': companion['cpf']!.text,
              'birthDate': companion['birthDate']!.text,
              'relationship': companion['relationship']!.text,
            })
        .toList();

    final documentsData = {
      'buyer': {
        'name': _buyerNameCtrl.text,
        'rg': _buyerRgCtrl.text,
        'cpf': _buyerCpfCtrl.text,
        'email': _buyerEmailCtrl.text,
        'birthDate': '', // Opcional para o comprador
      },
      'companions': companions,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalTermsScreen(
          hotelName: widget.hotelName,
          guests: widget.guests,
          companions: companions,
          onConfirm: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  itemName: widget.hotelName,
                  amount: widget.totalPrice,
                  userEmail: (documentsData['buyer'] as Map)['email'] ?? '',
                  userName: (documentsData['buyer'] as Map)['name'] ?? '',
                  onPaymentSuccess: () async {
                    // Salva a viagem e navega para o resumo via callback do reservation_screen
                    widget.onConfirm(documentsData);
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
        title: const Text('Documentos da Reserva'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações sobre documentos necessários
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Documentos Necessários',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Para completar sua reserva, precisamos dos seguintes documentos:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _docItem('RG (Registro Geral)', 'Frente e verso'),
                  _docItem('CPF', 'Número do CPF'),
                  _docItem('E-mail', 'Para confirmação da reserva'),
                  if (widget.guests > 1) ...[
                    const SizedBox(height: 8),
                    _docItem(
                      'Acompanhantes',
                      'RG, CPF, data de nascimento e relação com o comprador',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            // SEÇÃO DO COMPRADOR
            const Text(
              'Dados do Comprador',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Nome Completo',
              _buyerNameCtrl,
              Icons.person_outline,
              'Ex: João Silva Santos',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'RG (Registro Geral)',
              _buyerRgCtrl,
              Icons.card_giftcard_outlined,
              'Ex: 123456789',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'CPF',
              _buyerCpfCtrl,
              Icons.badge_outlined,
              'Ex: 123.456.789-00',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'E-mail',
              _buyerEmailCtrl,
              Icons.email_outlined,
              'Ex: joao@email.com',
              keyboardType: TextInputType.emailAddress,
            ),

            // SEÇÃO DE ACOMPANHANTES
            if (widget.guests > 1) ...[
              const SizedBox(height: 28),
              const Text(
                'Dados dos Acompanhantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _companionsControllers.length,
                itemBuilder: (context, index) {
                  final companion = _companionsControllers[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Acompanhante ${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'Nome Completo',
                        companion['name']!,
                        Icons.person_outline,
                        'Ex: Maria Silva Santos',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'RG',
                        companion['rg']!,
                        Icons.card_giftcard_outlined,
                        'Ex: 987654321',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'CPF',
                        companion['cpf']!,
                        Icons.badge_outlined,
                        'Ex: 987.654.321-00',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'Data de Nascimento',
                        companion['birthDate']!,
                        Icons.calendar_today_outlined,
                        'Ex: 15/03/1990',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        'Relação com o Comprador',
                        companion['relationship']!,
                        Icons.family_restroom_outlined,
                        'Ex: Cônjuge, Filho, Amigo',
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],

            // BOTÕES DE AÇÃO
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: AppColors.background,
      ),
    );
  }

  Widget _docItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
