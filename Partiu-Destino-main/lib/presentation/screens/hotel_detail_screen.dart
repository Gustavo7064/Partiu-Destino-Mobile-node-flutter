import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/app_provider.dart';
import '../../data/models/hotel.dart';
import 'reservation_screen.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: hotel.imageUrl.startsWith('data:')
                  ? Image.memory(
                      base64Decode(hotel.imageUrl.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.border,
                        child: const Icon(Icons.hotel,
                            size: 80, color: AppColors.textGrey),
                      ),
                    )
                  : Image.network(
                      hotel.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.border,
                        child: const Icon(Icons.hotel,
                            size: 80, color: AppColors.textGrey),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(hotel.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            )),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.star.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.star, size: 16),
                            const SizedBox(width: 4),
                            Text(hotel.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(hotel.location,
                          style: const TextStyle(
                              color: AppColors.textGrey, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem(
                            Icons.login_rounded, 'Check-in', hotel.checkinTime),
                        Container(
                            width: 1, height: 36, color: AppColors.border),
                        _infoItem(Icons.logout_rounded, 'Check-out',
                            hotel.checkoutTime),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Sobre',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(hotel.description,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          height: 1.6)),
                  const SizedBox(height: 24),
                  const Text('Detalhes Técnicos',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _techDetail(
                            Icons.bed_outlined, 'Quartos', '${hotel.bedrooms}'),
                        const Divider(height: 16),
                        _techDetail(Icons.bathtub_outlined, 'Banheiros',
                            '${hotel.bathrooms}'),
                        const Divider(height: 16),
                        _techDetail(
                            Icons.tv_outlined, 'Televisões', '${hotel.tvs}'),
                        const Divider(height: 16),
                        _techDetail(Icons.ac_unit, 'Ar-Condicionado',
                            hotel.hasAC ? 'Sim' : 'Não',
                            valueColor:
                                hotel.hasAC ? AppColors.success : Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Comodidades',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hotel.amenities
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(a,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Opções de Acomodação',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  // Lista de Quartos com Destaque para Luxo
                  if (hotel.roomTypes.isEmpty)
                    const Text('Apenas quarto padrão disponível.',
                        style: TextStyle(color: AppColors.textGrey))
                  else
                    ...hotel.roomTypes.map((rt) {
                      final isLuxo = rt.priceMultiplier > 1.2;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isLuxo
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isLuxo ? AppColors.primary : AppColors.border,
                            width: isLuxo ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(rt.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      if (isLuxo)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: const Text('RECOMENDADO',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(rt.description,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textGrey)),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Adicional: +${((rt.priceMultiplier - 1) * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                          color: isLuxo
                                              ? AppColors.primary
                                              : AppColors.textGrey,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_outline,
                                color: AppColors.primary),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  _regimentsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preço por noite',
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                Text(
                  'R\$ ${hotel.pricePerNight.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!prov.isLoggedIn) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Login necessário'),
                        content:
                            const Text('Faça login para reservar este hotel.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReservationScreen(hotel: hotel),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Reservar agora',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) => Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      );

  Widget _regimentsSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rule_outlined, color: Colors.orange, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Regimentos Internos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _regimentItem(Icons.pets, 'Animais de Estimação',
                'Proibido trazer animais de estimação ou animais exóticos nas acomodações.'),
            const SizedBox(height: 10),
            _regimentItem(Icons.volume_off, 'Barulho',
                'Ruídos excessivos não são permitidos entre 22h e 8h. Multa de R\$ 200 por violação.'),
            const SizedBox(height: 10),
            _regimentItem(Icons.cleaning_services, 'Limpeza',
                'Acomodação suja ou danificada resultará em taxa de limpeza de R\$ 150 ou mais.'),
            const SizedBox(height: 10),
            _regimentItem(Icons.person, 'Maioridade',
                'Hóspedes menores de 18 anos devem estar acompanhados de responsável legal. Cartas ou e-mails de responsáveis não são aceitos.'),
          ],
        ),
      );

  Widget _techDetail(IconData icon, String label, String value,
          {Color? valueColor}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: valueColor ?? AppColors.primary,
            ),
          ),
        ],
      );

  Widget _regimentItem(IconData icon, String title, String description) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
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
}
