import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/reservation.dart';

class ReservationSummaryScreen extends StatelessWidget {
  final Reservation reservation;
  final Map<String, dynamic> documentsData;

  const ReservationSummaryScreen({
    super.key,
    required this.reservation,
    required this.documentsData,
  });

  @override
  Widget build(BuildContext context) {
    final buyer = documentsData['buyer'] as Map<String, dynamic>;
    final companions = documentsData['companions'] as List;
    final fmt = DateFormat('dd/MM/yyyy');
    final curr = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resumo da Reserva'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generatePdf(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Dados da Hospedagem'),
            _buildInfoCard([
              _infoRow('Hotel', reservation.hotelName),
              _infoRow('Localização', reservation.location),
              _infoRow('Check-in', fmt.format(reservation.checkinDate)),
              _infoRow('Check-out', fmt.format(reservation.checkoutDate)),
              _infoRow('Total Pago', curr.format(reservation.totalPrice)),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Titular da Reserva'),
            _buildInfoCard([
              _infoRow('Nome', buyer['name']),
              _infoRow('CPF', buyer['cpf']),
              _infoRow('RG', buyer['rg']),
              _infoRow('E-mail', buyer['email']),
            ]),
            if (companions.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionTitle('Acompanhantes'),
              ...companions.map((c) => _buildInfoCard([
                    _infoRow('Nome', c['name']),
                    _infoRow('Parentesco', c['relationship']),
                    _infoRow('CPF', c['cpf']),
                  ])),
            ],
            const SizedBox(height: 30),
            _buildSectionTitle('Documentos Necessários no Check-in'),
            _buildInfoCard([
              const Text('• Documento original com foto de todos os hóspedes.',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
              const Text('• Comprovante desta reserva (digital ou impresso).',
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
            ]),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: const Text('VOLTAR AO INÍCIO',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final buyer = documentsData['buyer'] as Map;

    pdf.addPage(pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(
              level: 0, child: pw.Text('Voucher de Reserva - Partiu Destino')),
          pw.SizedBox(height: 20),
          pw.Text('Hotel: ${reservation.hotelName}'),
          pw.Text('Local: ${reservation.location}'),
          pw.Text('Titular: ${buyer['name']}'),
          pw.Text('CPF: ${buyer['cpf']}'),
          pw.SizedBox(height: 20),
          pw.Text(
              'Check-in: ${DateFormat('dd/MM/yyyy').format(reservation.checkinDate)}'),
          pw.Text(
              'Check-out: ${DateFormat('dd/MM/yyyy').format(reservation.checkoutDate)}'),
          pw.SizedBox(height: 40),
          pw.Divider(),
          pw.Text('Apresente este documento no balcão do hotel.'),
        ],
      ),
    ));

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
