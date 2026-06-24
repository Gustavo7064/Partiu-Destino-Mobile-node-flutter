import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_provider.dart';
import '../../core/constants/app_colors.dart';
import 'reservation_screen.dart';
import '../../data/models/hotel.dart';

class CustomTripScreen extends StatefulWidget {
  const CustomTripScreen({super.key});

  @override
  State<CustomTripScreen> createState() => _CustomTripScreenState();
}

class _CustomTripScreenState extends State<CustomTripScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers de Contato
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _allowWhatsapp = true;

  // Questionário
  bool _hasChildren = false;
  int _peopleCount = 1;
  int _childrenCount = 0;

  // Opções para os Dropdowns
  final List<String> _reasonOptions = [
    'Lazer',
    'Trabalho',
    'Lua de Mel',
    'Aniversário',
    'Outro'
  ];
  final List<String> _budgetOptions = [
    r'Até R$ 2.000',
    r'R$ 2.000 a R$ 5.000',
    r'R$ 5.000 a R$ 10.000',
    r'Acima de R$ 10.000'
  ];

  String _reason = 'Lazer';
  String _budget = r'Até R$ 2.000';

  final _objectivesController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _extraInfoController = TextEditingController();

  // Interesses
  final List<String> _selectedInterests = [];
  final List<String> _interestsOptions = [
    'Praias',
    'Gastronomia',
    'Museus',
    'Aventura',
    'Vida Noturna',
    'Compras',
    'Natureza'
  ];

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AppProvider>().user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _objectivesController.dispose();
    _activitiesController.dispose();
    _extraInfoController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _generateRecommendation();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _generateRecommendation() {
    final prov = context.read<AppProvider>();
    Hotel? recommendedHotel;

    // Verificar se há hotéis disponíveis
    if (prov.hotels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum hotel disponível no momento. Tente novamente mais tarde.')),
      );
      return;
    }

    // Lógica de recomendação baseada nos destinos existentes
    if (_selectedInterests.contains('Praias')) {
      recommendedHotel = prov.hotels.firstWhere(
        (h) => h.location.contains('Santos') || h.location.contains('Florianópolis') || h.location.contains('Jericoacoara'),
        orElse: () => prov.hotels.first,
      );
    } else if (_selectedInterests.contains('Natureza') || _selectedInterests.contains('Aventura')) {
      recommendedHotel = prov.hotels.firstWhere(
        (h) => h.location.contains('Bonito'),
        orElse: () => prov.hotels.first,
      );
    } else if (_reason == 'Lua de Mel' || _reason == 'Aniversário') {
      recommendedHotel = prov.hotels.firstWhere(
        (h) => h.location.contains('Gramado'),
        orElse: () => prov.hotels.first,
      );
    } else {
      recommendedHotel = prov.hotels.first;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 50),
            const SizedBox(height: 10),
            Text("Sugestão: ${recommendedHotel!.name}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGuideItem(Icons.location_on, "Localização:", recommendedHotel.location),
              _buildGuideItem(Icons.info_outline, "Sobre:", recommendedHotel.description),
              _buildGuideItem(Icons.bed_outlined, "Acomodação:", "${recommendedHotel.bedrooms} quartos e ${recommendedHotel.bathrooms} banheiros"),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200)),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.child_care, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                            child: Text(
                                "POLÍTICA DE CRIANÇAS:",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Crianças com até 12 anos têm 40% de desconto na diária. A partir de 13 anos, cobrança integral.",
                      style: TextStyle(color: Colors.blue.shade800, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200)),
                child: const Row(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.green),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            "BRINDE: Se fechar agora, você ganha 1 NOITE EXTRA GRÁTIS!",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Refazer")),
                  ElevatedButton(
                    onPressed: () => _finalizeRequest(recommendedHotel!, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text("Aceitar e Finalizar"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _finalizeRequest(recommendedHotel!, false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text("Ainda não estou satisfeito / Não é isso"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
              child: RichText(
                  text: TextSpan(
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                TextSpan(
                    text: "$title ",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: desc)
              ]))),
        ],
      ),
    );
  }

  Future<void> _finalizeRequest(Hotel hotel, bool accepted) async {
    Navigator.pop(context); // Fecha o dialog de sugestão
    setState(() => _isSending = true);

    // Envia o pedido para o banco de dados (Admin verá o status)
    final success = await context.read<AppProvider>().sendCustomRequest(
          userName: _nameController.text,
          userEmail: _emailController.text,
          userPhone: _phoneController.text,
          allowWhatsapp: _allowWhatsapp,
          hasChildren: _hasChildren,
          peopleCount: _peopleCount,
          reason: _reason,
          budget: _budget,
          objectives: _objectivesController.text,
          activities: _activitiesController.text,
          extraInfo: _extraInfoController.text,
          interests: _selectedInterests.join(', '),
          suggestedDestination:
              accepted ? hotel.name : "${hotel.name} (RECUSADO)",
        );

    setState(() => _isSending = false);

    if (success) {
      if (!mounted) return;
      if (accepted) {
        // Se aceitou, leva para a tela de reserva normal
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationScreen(
              hotel: hotel,
            ),
          ),
        );
      } else {
        // Se não ficou satisfeito, mostra aviso e volta para home
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Entendido!"),
            content: const Text(
                "Nossa equipe recebeu suas preferências e entrará em contato em breve para montar um roteiro exclusivo que seja a sua cara!"),
            actions: [
              TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text("OK"))
            ],
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Erro ao enviar pedido. Verifique sua conexão e tente novamente.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Viagem Personalizada"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isSending
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                LinearProgressIndicator(
                    value: (_currentPage + 1) / 4,
                    backgroundColor: Colors.grey.shade200,
                    color: AppColors.primary),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                      _buildStep4(),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Vamos começar pelos seus contatos",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 10),
          const Text("Como nossa equipe pode falar com você?",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          _buildTextField(_nameController, "Seu Nome Completo", Icons.person),
          _buildTextField(_emailController, "Seu E-mail", Icons.email,
              keyboardType: TextInputType.emailAddress),
          _buildTextField(
              _phoneController, "Seu Telefone / WhatsApp", Icons.phone,
              keyboardType: TextInputType.phone),
          SwitchListTile(
            title: const Text("Autorizo contato via WhatsApp",
                style: TextStyle(fontSize: 14)),
            value: _allowWhatsapp,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _allowWhatsapp = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sobre os viajantes",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 25),
          const Text("Quantas pessoas vão na viagem?",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildNumberField(
            value: _peopleCount,
            onChanged: (val) => setState(() => _peopleCount = val),
            label: "Total de Viajantes",
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text("Terá crianças na viagem?"),
            subtitle: const Text("Abaixo de 12 anos têm 40% de desconto", style: TextStyle(fontSize: 11)),
            value: _hasChildren,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() {
              _hasChildren = val ?? false;
              if (!_hasChildren) _childrenCount = 0;
            }),
          ),
          if (_hasChildren) ...[
            const SizedBox(height: 10),
            _buildNumberField(
              value: _childrenCount,
              onChanged: (val) => setState(() => _childrenCount = val),
              label: "Quantas crianças?",
            ),
          ],
          const SizedBox(height: 20),
          const Text("Qual o motivo principal?",
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            isExpanded: true,
            value: _reason,
            items: _reasonOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) => setState(() => _reason = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({required int value, required ValueChanged<int> onChanged, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Row(
            children: [
              IconButton(
                onPressed: () => onChanged(value > 0 ? value - 1 : 0),
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  "$value",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Objetivos e Orçamento",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 25),
          const Text("Quanto pretende investir (por pessoa)?",
              style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            isExpanded: true,
            value: _budget,
            items: _budgetOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) => setState(() => _budget = val!),
          ),
          const SizedBox(height: 20),
          _buildTextField(_objectivesController,
              "Quais seus objetivos nessa viagem?", Icons.flag,
              maxLines: 3),
          _buildTextField(_activitiesController,
              "O que você pretende fazer lá?", Icons.directions_run,
              maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Para finalizar...",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 25),
          const Text("Selecione seus interesses:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _interestsOptions.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _buildTextField(_extraInfoController,
              "Alguma outra informação importante?", Icons.info_outline,
              maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(onPressed: _previousPage, child: const Text("Voltar"))
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text(
                _currentPage == 3 ? "Gerar Minha Recomendação" : "Próximo"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
