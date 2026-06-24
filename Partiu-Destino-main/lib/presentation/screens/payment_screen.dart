import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../services/mercado_pago_service.dart';

class PaymentScreen extends StatefulWidget {
  final String itemName;
  final double amount;
  final String userEmail;
  final String userName;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.itemName,
    required this.amount,
    required this.userEmail,
    required this.userName,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _mpService = MercadoPagoService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final curr = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pagamento'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined,
                  color: AppColors.primary, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Ambiente de Demonstração',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolha como deseja prosseguir com o pagamento:',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),

              // Card de Resumo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: [
                    Text(widget.itemName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      curr.format(widget.amount),
                      style: const TextStyle(
                          fontSize: 28,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // OPÇÃO 1: MERCADO PAGO REAL
              _actionButton(
                title: 'Mercado Pago',
                subtitle: 'Abre o navegador com o valor real',
                icon: Icons.open_in_browser,
                color: Colors.blue.shade700,
                onPressed: _isLoading ? null : _redirectToMercadoPago,
              ),

              const SizedBox(height: 16),

              // OPÇÃO 2: CONFIRMAÇÃO DIRETA
              _actionButton(
                title: 'Confirmar Direto',
                subtitle: 'Simula sucesso e salva no banco',
                icon: Icons.check_circle_outline,
                color: Colors.green.shade600,
                onPressed: _isLoading ? null : _simulateDirectSuccess,
              ),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar Operação',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _redirectToMercadoPago() async {
    setState(() => _isLoading = true);
    final result = await _mpService.createPaymentPreference(
      title: widget.itemName,
      unitPrice: widget.amount,
      payerEmail: widget.userEmail,
    );
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final String url = result['sandbox_init_point'] ?? result['init_point'];
      if (await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        _showTccDialog(
            'Link aberto no navegador! Ao retornar, você poderá simular a confirmação para ver a viagem salva.');
      }
    }
  }

  void _simulateDirectSuccess() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);

      // No fluxo do TCC, chamamos o callback que salva a viajem
      widget.onPaymentSuccess();

      // E agora, em vez de voltar para a home, vamos mostrar o RESUMO (Extrato)
      // para que o usuário veja os dados confirmados imediatamente.
      // O widget.onPaymentSuccess já deve cuidar do salvamento.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pagamento Confirmado! Gerando seu resumo...'),
            backgroundColor: Colors.green),
      );
    });
  }

  void _showTccDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demonstração pagamento'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
      ),
    );
  }
}
