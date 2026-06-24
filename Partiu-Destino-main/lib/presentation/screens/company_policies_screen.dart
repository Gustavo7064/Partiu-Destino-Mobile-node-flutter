import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';

class CompanyPoliciesScreen extends StatelessWidget {
  const CompanyPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Políticas da Empresa'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Imprimir / Salvar PDF',
            onPressed: () => _generatePdf(context),
          ),
        ],
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
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.policy_outlined, color: AppColors.primary, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Termos de Uso e Políticas de Privacidade',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Partiu Destino — Plataforma de Hospedagens, Passagens Aéreas e Viagens',
                    style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Última atualização: Junho de 2026',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('1. Uso da Plataforma'),
            _buildInfoCard([
              _buildPolicyText(
                'A plataforma Partiu Destino é destinada à consulta, organização e reserva de serviços turísticos, incluindo hospedagens, passagens aéreas e viagens personalizadas. O usuário se compromete a utilizar os serviços de forma lícita, ética e em conformidade com as normas vigentes.',
              ),
              _buildPolicyText(
                'É vedado o uso da plataforma para fins fraudulentos, ilegais ou que violem direitos de terceiros. A Partiu Destino reserva-se o direito de suspender ou cancelar contas que violem estes termos.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('2. Hospedagens: Reservas e Cancelamentos'),
            _buildInfoCard([
              _buildPolicyItem(
                Icons.hotel_outlined,
                'Confirmação de Hospedagem',
                'Toda reserva de hospedagem é confirmada após a aprovação do pagamento. O comprovante e o resumo da reserva ficam disponíveis em Minhas Viagens.',
              ),
              _buildPolicyItem(
                Icons.cancel_outlined,
                'Cancelamento de Hospedagem',
                'Cancelamentos realizados com mais de 48 horas de antecedência ao check-in terão reembolso integral. Cancelamentos com menos de 48 horas poderão estar sujeitos a taxas conforme a política do estabelecimento.',
              ),
              _buildPolicyItem(
                Icons.swap_horiz_outlined,
                'Alterações de Hospedagem',
                'Alterações de datas, quantidade de hóspedes, quartos ou acomodações estão sujeitas à disponibilidade e podem gerar diferença de valores.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('3. Passagens Aéreas: Reservas e Embarque'),
            _buildInfoCard([
              _buildPolicyItem(
                Icons.flight_takeoff,
                'Confirmação da Passagem',
                'A passagem aérea é confirmada após o pagamento e fica disponível em Minhas Viagens, com resumo de origem, destino, horários, aeronave, passageiros, assentos e valor total.',
              ),
              _buildPolicyItem(
                Icons.event_seat_outlined,
                'Escolha de Assentos',
                'O usuário poderá selecionar assentos disponíveis no mapa do avião. Assentos já ocupados não poderão ser escolhidos. Alterações de assento podem depender de disponibilidade.',
              ),
              _buildPolicyItem(
                Icons.schedule_outlined,
                'Horário de Embarque',
                'O usuário deve comparecer ao aeroporto com antecedência. Atrasos, ausência no embarque ou dados incorretos podem impedir a viagem, sem garantia de reembolso.',
              ),
              _buildPolicyItem(
                Icons.badge_outlined,
                'Documentação Obrigatória',
                'Todos os passageiros devem apresentar documento oficial com foto no embarque. Os dados informados na reserva devem corresponder aos documentos apresentados.',
              ),
              _buildPolicyItem(
                Icons.pets_outlined,
                'Animais no Avião',
                'Animais não são permitidos nas comodidades do avião nesta modalidade de reserva. O descumprimento poderá impedir o embarque.',
              ),
              _buildPolicyItem(
                Icons.security_outlined,
                'Tolerância Zero e Segurança',
                'Comportamento inadequado, agressivo ou descumprimento de regras de segurança poderá resultar no impedimento do embarque ou cancelamento da reserva.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('4. Política de Crianças e Menores'),
            _buildInfoCard([
              _buildPolicyItem(
                Icons.child_care,
                'Crianças em Hospedagens',
                'Crianças com até 12 anos (inclusive) podem ter desconto sobre o valor da diária, conforme regra da hospedagem. A partir de 13 anos, o valor integral pode ser cobrado.',
              ),
              _buildPolicyItem(
                Icons.family_restroom,
                'Acompanhamento de Menores',
                'Hóspedes ou passageiros menores de 18 anos devem estar acompanhados de responsável legal quando exigido. Cartas ou e-mails de responsáveis NÃO substituem documentação oficial quando necessária.',
              ),
              _buildPolicyItem(
                Icons.badge_outlined,
                'Documentação de Menores',
                'Menores devem apresentar documento de identificação original e, quando aplicável, autorização formal para viagem, conforme exigências legais e operacionais.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('5. Regras de Conduta na Hospedagem'),
            _buildInfoCard([
              _buildPolicyItem(
                Icons.volume_off_outlined,
                'Política de Ruído',
                'Ruídos excessivos entre 22h e 8h poderão resultar em multa de R\$ 200,00. O hóspede é responsável por manter o silêncio nos horários restritos.',
              ),
              _buildPolicyItem(
                Icons.cleaning_services_outlined,
                'Taxa de Limpeza e Danos',
                'Acomodações sujas ou danificadas poderão resultar em taxa de limpeza de R\$ 150,00 ou mais, conforme avaliação da administração do estabelecimento.',
              ),
              _buildPolicyItem(
                Icons.pets_outlined,
                'Animais de Estimação',
                'Animais de estimação e animais exóticos são proibidos nas acomodações, salvo quando houver regra expressa em contrário. Violações podem resultar em cancelamento sem reembolso.',
              ),
              _buildPolicyItem(
                Icons.smoke_free_outlined,
                'Proibição de Fumo',
                'É proibido fumar dentro das acomodações e em áreas comuns cobertas. Áreas externas designadas podem estar disponíveis conforme o estabelecimento.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('6. Pagamentos, Comprovantes e Minhas Viagens'),
            _buildInfoCard([
              _buildPolicyItem(
                Icons.payment_outlined,
                'Pagamento',
                'O pagamento poderá ser realizado por meio das opções disponíveis na plataforma. Em ambiente de demonstração, a confirmação pode ser simulada para fins acadêmicos.',
              ),
              _buildPolicyItem(
                Icons.receipt_long_outlined,
                'Comprovantes',
                'Após a confirmação, o usuário poderá consultar o resumo da hospedagem ou passagem aérea em Minhas Viagens.',
              ),
              _buildPolicyItem(
                Icons.category_outlined,
                'Tipos de Reserva',
                'As reservas poderão ser identificadas como Hospedagem, Passagem aérea ou, futuramente, Combo/Pacote completo quando incluir hospedagem e passagem em uma única compra.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('7. Privacidade e Proteção de Dados'),
            _buildInfoCard([
              _buildPolicyText(
                'A Partiu Destino está comprometida com a proteção dos dados pessoais dos usuários, em conformidade com a Lei Geral de Proteção de Dados (LGPD — Lei nº 13.709/2018).',
              ),
              _buildPolicyItem(
                Icons.lock_outline,
                'Coleta de Dados',
                'Coletamos apenas os dados necessários para reservas e passagens: nome, documento, data de nascimento, telefone, e-mail, dados de hóspedes, acompanhantes e passageiros.',
              ),
              _buildPolicyItem(
                Icons.share_outlined,
                'Compartilhamento',
                'Os dados não são vendidos. Eles podem ser utilizados somente para viabilizar a reserva junto a hotéis, parceiros, companhias aéreas ou canais necessários à operação.',
              ),
              _buildPolicyItem(
                Icons.delete_outline,
                'Exclusão de Dados',
                'O usuário pode solicitar a exclusão de seus dados a qualquer momento pelo e-mail: contato@partiudestino.com.br.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('8. Responsabilidades'),
            _buildInfoCard([
              _buildPolicyText(
                'A Partiu Destino atua como intermediária entre o usuário e os serviços turísticos, como hospedagens, passagens e parceiros. Não nos responsabilizamos por falhas causadas diretamente por terceiros, estabelecimentos ou companhias aéreas.',
              ),
              _buildPolicyText(
                'O usuário é responsável pela veracidade das informações fornecidas. Dados incorretos, incompletos ou fraudulentos podem resultar no cancelamento da reserva, impedimento de embarque ou perda do serviço contratado.',
              ),
            ]),
            const SizedBox(height: 16),

            _buildSectionTitle('9. Contato e Suporte'),
            _buildInfoCard([
              _buildPolicyItem(Icons.email_outlined, 'E-mail', 'contato@partiudestino.com.br'),
              _buildPolicyItem(Icons.phone_outlined, 'Telefone / WhatsApp', '(11) 99999-0000 — Atendimento de segunda a sexta, das 9h às 18h.'),
              _buildPolicyItem(Icons.language_outlined, 'Site Oficial', 'www.partiudestino.com.br'),
            ]),
            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ao utilizar a plataforma Partiu Destino, você declara ter lido, compreendido e concordado com todos os termos e políticas descritos neste documento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildPolicyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.6),
      ),
    );
  }

  Widget _buildPolicyItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Políticas da Empresa — Partiu Destino',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Última atualização: Junho de 2026', style: const pw.TextStyle(fontSize: 11)),
          pw.Divider(),
          pw.SizedBox(height: 10),
          _pdfSection('1. Uso da Plataforma', 'A plataforma Partiu Destino permite reservas de hospedagens, passagens aéreas e organização de viagens. O usuário deve utilizar os serviços de forma lícita e ética.'),
          _pdfSection('2. Hospedagens: Reservas e Cancelamentos', '• Reserva confirmada após pagamento.\n• Cancelamentos com mais de 48h do check-in: reembolso integral.\n• Alterações dependem de disponibilidade e podem gerar diferença de valores.'),
          _pdfSection('3. Passagens Aéreas: Reservas e Embarque', '• A passagem é confirmada após pagamento e aparece em Minhas Viagens.\n• O usuário escolhe assentos disponíveis.\n• Todos os passageiros devem apresentar documento oficial com foto.\n• É necessário comparecer ao aeroporto com antecedência.\n• Animais não são permitidos nas comodidades do avião nesta reserva.\n• Há tolerância zero para comportamento inadequado ou descumprimento de regras de segurança.'),
          _pdfSection('4. Política de Crianças e Menores', 'Menores de idade devem estar acompanhados de responsável legal quando exigido e apresentar documentação oficial. Cartas ou e-mails não substituem autorização/documentação exigida.'),
          _pdfSection('5. Regras de Conduta na Hospedagem', '• Silêncio entre 22h e 8h.\n• Taxas por limpeza excessiva ou danos.\n• Animais são proibidos nas acomodações, salvo regra expressa em contrário.\n• Fumo é proibido em áreas internas e cobertas.'),
          _pdfSection('6. Pagamentos, Comprovantes e Minhas Viagens', 'Após a confirmação, o usuário poderá consultar o resumo da hospedagem ou passagem aérea em Minhas Viagens. Reservas podem ser identificadas como Hospedagem, Passagem aérea ou futuramente Combo/Pacote completo.'),
          _pdfSection('7. Privacidade e Proteção de Dados (LGPD)', 'Coletamos apenas dados necessários para reservas: nome, documento, data de nascimento, telefone, e-mail, dados de hóspedes e passageiros. Os dados não são vendidos a terceiros.'),
          _pdfSection('8. Responsabilidades', 'A Partiu Destino atua como intermediária. O usuário é responsável pela veracidade dos dados. Dados incorretos podem resultar em cancelamento, impedimento de embarque ou perda do serviço.'),
          _pdfSection('9. Contato e Suporte', 'E-mail: contato@partiudestino.com.br\nTelefone/WhatsApp: (11) 99999-0000\nSite: www.partiudestino.com.br'),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'Ao utilizar a plataforma Partiu Destino, você declara ter lido, compreendido e concordado com todos os termos e políticas descritos neste documento.',
            style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(content, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }
}
