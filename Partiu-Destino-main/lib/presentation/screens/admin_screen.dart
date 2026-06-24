import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/app_provider.dart';
import '../../data/models/user.dart';
import '../../data/models/trip.dart';
import '../../data/models/hotel.dart';
import '../../data/models/flight.dart';
import '../../core/constants/app_colors.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  static const int _homeIndex = 0;
  static const int _hospedagensIndex = 1;
  static const int _passagensIndex = 2;
  static const int _administracaoIndex = 3;
  static const int _financeiroHospedagensIndex = 4;
  static const int _reservasIndex = 5;
  static const int _hoteisIndex = 6;
  static const int _financeiroPassagensIndex = 7;
  static const int _passagensCompradasIndex = 8;
  static const int _voosIndex = 9;
  static const int _usuariosIndex = 10;
  static const int _personalizacaoIndex = 11;

  final List<_AdminMenuItem> _menuItems = const [
    _AdminMenuItem(
      title: 'Início',
      subtitle: 'Tela inicial com os principais grupos de gestão do administrador.',
      icon: Icons.home_rounded,
    ),
    _AdminMenuItem(
      title: 'Hospedagens',
      subtitle: 'Gerencie tudo relacionado a hotéis: reservas, check-in, check-out, quartos, valores e financeiro das hospedagens.',
      icon: Icons.hotel_rounded,
    ),
    _AdminMenuItem(
      title: 'Passagens',
      subtitle: 'Gerencie tudo relacionado a passagens aéreas: voos, compradores, passageiros, assentos, edições e resumo financeiro das vendas.',
      icon: Icons.airplane_ticket_rounded,
    ),
    _AdminMenuItem(
      title: 'Administração',
      subtitle: 'Acesse usuários, pedidos personalizados, permissões e configurações gerais da plataforma.',
      icon: Icons.admin_panel_settings_rounded,
    ),
  ];

  String get _currentTitle {
    switch (_selectedIndex) {
      case _homeIndex:
        return 'Gestão Partiu Destino';
      case _hospedagensIndex:
        return 'Gerenciar Hospedagens';
      case _passagensIndex:
        return 'Gerenciar Passagens';
      case _administracaoIndex:
        return 'Administração';
      case _financeiroHospedagensIndex:
        return 'Financeiro de Hospedagens';
      case _reservasIndex:
        return 'Reservas de Hotéis';
      case _hoteisIndex:
        return 'Hotéis';
      case _financeiroPassagensIndex:
        return 'Financeiro de Passagens';
      case _passagensCompradasIndex:
        return 'Passagens Compradas';
      case _voosIndex:
        return 'Voos';
      case _usuariosIndex:
        return 'Usuários';
      case _personalizacaoIndex:
        return 'Personalização';
      default:
        return 'Painel Administrativo';
    }
  }

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  int _getBackIndex() {
    if (_selectedIndex == _hospedagensIndex ||
        _selectedIndex == _passagensIndex ||
        _selectedIndex == _administracaoIndex) {
      return _homeIndex;
    }

    if (_selectedIndex == _financeiroHospedagensIndex ||
        _selectedIndex == _reservasIndex ||
        _selectedIndex == _hoteisIndex) {
      return _hospedagensIndex;
    }

    if (_selectedIndex == _financeiroPassagensIndex ||
        _selectedIndex == _passagensCompradasIndex ||
        _selectedIndex == _voosIndex) {
      return _passagensIndex;
    }

    if (_selectedIndex == _usuariosIndex || _selectedIndex == _personalizacaoIndex) {
      return _administracaoIndex;
    }

    return _homeIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        leading: _selectedIndex == _homeIndex
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Voltar',
                onPressed: () => _goToTab(_getBackIndex()),
              ),
        title: Text(_currentTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair do Painel',
            onPressed: () {
              context.read<AppProvider>().logout();
              Navigator.of(context).pushReplacementNamed('/home');
            },
          )
        ],
      ),
      drawer: isWide ? null : _buildDrawer(context),
      body: Container(
        color: Colors.grey[100],
        child: Row(
          children: [
            if (isWide) _buildSideMenu(context),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _AdminHomeTab(
                    menuItems: _menuItems,
                    onSelect: _goToTab,
                  ),
                  _AdminHubTab(
                    title: 'Gerenciar Hospedagens',
                    subtitle: 'Aqui ficam todas as ações ligadas a hotéis, reservas, check-in, check-out, quartos e resultado financeiro das hospedagens.',
                    cards: [
                      _AdminHubCardData(
                        title: 'Resumo financeiro das hospedagens',
                        subtitle: 'Veja faturamento de hotéis, valores a receber, ticket médio, total de reservas, gráficos e histórico mensal.',
                        icon: Icons.dashboard_rounded,
                        targetIndex: _financeiroHospedagensIndex,
                      ),
                      _AdminHubCardData(
                        title: 'Reservas de hotéis',
                        subtitle: 'Acompanhe reservas feitas pelos usuários, status, check-in, check-out e histórico de alterações.',
                        icon: Icons.card_travel_rounded,
                        targetIndex: _reservasIndex,
                      ),
                      _AdminHubCardData(
                        title: 'Cadastro de hotéis',
                        subtitle: 'Cadastre e edite hotéis, quartos, valores, imagens, comodidades e disponibilidade.',
                        icon: Icons.hotel_rounded,
                        targetIndex: _hoteisIndex,
                      ),
                    ],
                    onSelect: _goToTab,
                  ),
                  _AdminHubTab(
                    title: 'Gerenciar Passagens Aéreas',
                    subtitle: 'Aqui ficam todas as ações ligadas a voos, vendas de passagens, passageiros, assentos e faturamento das passagens.',
                    cards: [
                      _AdminHubCardData(
                        title: 'Resumo financeiro das passagens',
                        subtitle: 'Veja quanto foi vendido em passagens, valores pendentes, ticket médio, total de passagens e faturamento por destino.',
                        icon: Icons.payments_rounded,
                        targetIndex: _financeiroPassagensIndex,
                      ),
                      _AdminHubCardData(
                        title: 'Passagens compradas',
                        subtitle: 'Veja compradores, passageiros, assentos, dados da passagem, status e histórico de edições feitas pelo admin.',
                        icon: Icons.airplane_ticket_rounded,
                        targetIndex: _passagensCompradasIndex,
                      ),
                      _AdminHubCardData(
                        title: 'Cadastro de voos',
                        subtitle: 'Cadastre e edite voos, origem, destino, datas, horários, aeronave, assentos e preços.',
                        icon: Icons.flight_rounded,
                        targetIndex: _voosIndex,
                      ),
                    ],
                    onSelect: _goToTab,
                  ),
                  _AdminHubTab(
                    title: 'Administração Geral',
                    subtitle: 'Aqui ficam as ações gerais da plataforma, como usuários e solicitações personalizadas dos clientes.',
                    cards: [
                      _AdminHubCardData(
                        title: 'Usuários',
                        subtitle: 'Consulte usuários cadastrados, dados do perfil, permissões e informações da conta.',
                        icon: Icons.group_rounded,
                        targetIndex: _usuariosIndex,
                      ),
                      _AdminHubCardData(
                        title: 'Personalização',
                        subtitle: 'Gerencie pedidos personalizados, preferências dos clientes, banners e experiências especiais.',
                        icon: Icons.auto_awesome_rounded,
                        targetIndex: _personalizacaoIndex,
                      ),
                    ],
                    onSelect: _goToTab,
                  ),
                  const FinancialPanelTab(),
                  const TripListTab(),
                  const HotelCatalogTab(),
                  const FlightFinancialPanelTab(),
                  const FlightReservationsAdminTab(),
                  const FlightsManagementTab(),
                  const UserListTab(),
                  const CustomRequestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 34),
                  SizedBox(height: 10),
                  Text(
                    'Painel Administrativo',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Partiu Destino',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final selected = _selectedIndex == index;
                  return ListTile(
                    selected: selected,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                    leading: Icon(item.icon, color: selected ? AppColors.primary : Colors.grey[700]),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        color: selected ? AppColors.primary : Colors.grey[850],
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _goToTab(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Partiu Destino', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final selected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _goToTab(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Icon(item.icon, color: selected ? AppColors.primary : Colors.grey[700]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                    color: selected ? AppColors.primary : Colors.grey[850],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _AdminMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _AdminHomeTab extends StatelessWidget {
  final List<_AdminMenuItem> menuItems;
  final ValueChanged<int> onSelect;

  const _AdminHomeTab({
    super.key,
    required this.menuItems,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final actionItems = menuItems.asMap().entries.where((entry) => entry.key != 0).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo ao Painel Administrativo',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Escolha uma ação abaixo para acessar exatamente o que deseja consultar ou alterar no sistema.',
                      style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'O que você deseja fazer?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Cada opção abaixo mostra o que será encontrado dentro da área, facilitando a navegação do administrador.',
                style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actionItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 2 : 1,
                  mainAxisExtent: 158,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final entry = actionItems[index];
                  final item = entry.value;
                  return _AdminActionCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    onTap: () => onSelect(entry.key),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}


class _AdminHubCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final int targetIndex;

  const _AdminHubCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.targetIndex,
  });
}

class _AdminHubTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_AdminHubCardData> cards;
  final ValueChanged<int> onSelect;

  const _AdminHubTab({
    required this.title,
    required this.subtitle,
    required this.cards,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 2 : 1,
                  mainAxisExtent: 166,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _AdminActionCard(
                    title: card.title,
                    subtitle: card.subtitle,
                    icon: card.icon,
                    onTap: () => onSelect(card.targetIndex),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserListTab extends StatefulWidget {
  const UserListTab({super.key});

  @override
  State<UserListTab> createState() => _UserListTabState();
}

class _UserListTabState extends State<UserListTab> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = context.read<AppProvider>().getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('Nenhum usuário cadastrado.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _usersFuture = context.read<AppProvider>().getAllUsers();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: user.profileImage != null &&
                            user.profileImage!.isNotEmpty
                        ? MemoryImage(
                            base64Decode(user.profileImage!.split(',').last))
                        : null,
                    child: (user.profileImage == null ||
                            user.profileImage!.isEmpty)
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                  title: Text(user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email),
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                          child: const Row(children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text("Editar")
                          ]),
                          onTap: () => _showEditUserDialog(context, user)),
                      PopupMenuItem(
                          child: const Row(children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Excluir", style: TextStyle(color: Colors.red))
                          ]),
                          onTap: () => _confirmDeleteUser(context, user)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final passCtrl = TextEditingController();
    String? base64Image = user.profileImage;
    String role = user.role ?? 'user';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Usuário'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 50);
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setDialogState(() => base64Image =
                          'data:image/jpeg;base64,${base64Encode(bytes)}');
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        base64Image != null && base64Image!.isNotEmpty
                            ? MemoryImage(
                                base64Decode(base64Image!.split(',').last))
                            : null,
                    child: (base64Image == null || base64Image!.isEmpty)
                        ? const Icon(Icons.add_a_photo)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome')),
                TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'E-mail')),
                TextField(
                    controller: passCtrl,
                    decoration: const InputDecoration(
                        labelText:
                            'Nova Senha (deixe vazio para não alterar)')),
                DropdownButton<String>(
                  value: role,
                  isExpanded: true,
                  items: ['user', 'admin']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => role = v ?? 'user'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final success =
                    await context.read<AppProvider>().adminUpdateUser(
                          User(
                            id: user.id,
                            name: nameCtrl.text,
                            email: emailCtrl.text,
                            role: role,
                            profileImage: base64Image,
                          ),
                          newPassword:
                              passCtrl.text.isNotEmpty ? passCtrl.text : null,
                        );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (success) {
                    setState(() {
                      _usersFuture = context.read<AppProvider>().getAllUsers();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usuário atualizado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Erro ao atualizar usuário. Verifique a conexão.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Usuário'),
        content: Text('Deseja remover ${user.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success =
                  await context.read<AppProvider>().deleteUser(user.id);
              if (context.mounted) {
                Navigator.pop(ctx);
                if (success) setState(() {});
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class TripListTab extends StatefulWidget {
  const TripListTab({super.key});

  @override
  State<TripListTab> createState() => _TripListTabState();
}

class _TripListTabState extends State<TripListTab> {
  final _fmt = DateFormat('dd/MM/yyyy');
  late Future<List<Trip>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = context.read<AppProvider>().getAllTrips();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _tripsFuture = context.read<AppProvider>().getAllTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trip>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final trips = snapshot.data ?? [];
        if (trips.isEmpty) {
          return const Center(child: Text('Nenhuma reserva encontrada.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _tripsFuture = context.read<AppProvider>().getAllTrips();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.hotelName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Text('Viajante: ${trip.userName ?? "Desconhecido"}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Status: ${trip.status.toUpperCase()}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Check-in: ${_fmt.format(trip.travelDate)}'),
                          const Spacer(),
                          Text(
                              'Check-out: ${trip.checkoutDate != null ? _fmt.format(trip.checkoutDate!) : "-"}'),
                        ],
                      ),
                      if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.sticky_note_2_outlined,
                                  size: 15, color: Colors.orange),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _firstLineOf(trip.notes!),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black87),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showHistoryDialog(context, trip,
                                onUpdated: _reload),
                            icon: const Icon(Icons.history, size: 16),
                            label: const Text('Histórico'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.orange),
                          ),
                          TextButton.icon(
                            onPressed: () => _showEditTripDialog(context, trip,
                                onSaved: _reload),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Editar Reserva'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────
  String _firstLineOf(String notes) {
    final lines = notes.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.isNotEmpty ? lines.first : notes;
  }

  List<Map<String, String>> _parseHistory(String notes) {
    final entries = <Map<String, String>>[];
    final blocks = notes.split('\n---\n');
    for (final block in blocks) {
      if (block.trim().isEmpty) continue;
      final lines = block.trim().split('\n');
      String admin = '', motivo = '', datas = '', anotacoes = '', obs = '';
      for (final line in lines) {
        if (line.startsWith('[Alteração por: ')) {
          admin = line
              .replaceAll('[Alteração por: ', '')
              .replaceAll(']', '')
              .trim();
        } else if (line.startsWith('Motivo: ')) {
          motivo = line.substring('Motivo: '.length).trim();
        } else if (line.startsWith('Datas: ')) {
          datas = line.substring('Datas: '.length).trim();
        } else if (line.startsWith('Anotações: ')) {
          anotacoes = line.substring('Anotações: '.length).trim();
        } else {
          if (obs.isNotEmpty) obs += ' ';
          obs += line.trim();
        }
      }
      if (admin.isNotEmpty ||
          motivo.isNotEmpty ||
          datas.isNotEmpty ||
          anotacoes.isNotEmpty ||
          obs.isNotEmpty) {
        entries.add({
          'admin': admin,
          'motivo': motivo,
          'datas': datas,
          'anotacoes': anotacoes,
          'obs': obs.trim()
        });
      }
    }
    return entries.reversed.toList();
  }

  // ── History dialog ────────────────────────────────────────────────────────
  void _showHistoryDialog(BuildContext context, Trip trip,
      {VoidCallback? onUpdated}) {
    final notesNotifier = ValueNotifier<String>(trip.notes ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: notesNotifier,
        builder: (context, currentNotes, _) {
          final entries = currentNotes.isNotEmpty
              ? _parseHistory(currentNotes)
              : <Map<String, String>>[];
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollCtrl) => Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.history, color: Colors.orange, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Histórico de Anotações',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            Text(trip.hotelName,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text('\${entries.length} registro(s)',
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.orange.withValues(alpha: 0.12),
                        labelStyle: const TextStyle(color: Colors.orange),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nova Anotação'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAddAnnotationDialog(
                        context,
                        trip,
                        onSaved: (newNotes) {
                          notesNotifier.value = newNotes;
                          onUpdated?.call();
                        },
                      ),
                    ),
                  ),
                ),
                const Divider(height: 8),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sticky_note_2_outlined,
                                  size: 52, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              const Text('Nenhuma anotação ainda.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15)),
                              const SizedBox(height: 6),
                              const Text('Use o botão acima para adicionar.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final e = entries[i];
                            final isLatest = i == 0;
                            return Container(
                              decoration: BoxDecoration(
                                color: isLatest
                                    ? Colors.orange.withValues(alpha: 0.06)
                                    : Colors.grey.withValues(alpha: 0.04),
                                border: Border.all(
                                    color: isLatest
                                        ? Colors.orange.withValues(alpha: 0.4)
                                        : Colors.grey.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: isLatest
                                            ? Colors.orange
                                                .withValues(alpha: 0.15)
                                            : Colors.grey
                                                .withValues(alpha: 0.15),
                                        child: Icon(Icons.person,
                                            size: 16,
                                            color: isLatest
                                                ? Colors.orange
                                                : Colors.grey),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                            e['admin']!.isNotEmpty
                                                ? e['admin']!
                                                : 'Admin',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ),
                                      if (isLatest)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: const Text('Mais recente',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  if (e['motivo']!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    _historyRow(
                                        Icons.edit_note, 'Motivo', e['motivo']!)
                                  ],
                                  if ((e['datas'] ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    _historyRow(
                                        Icons.date_range, 'Datas', e['datas']!)
                                  ],
                                  if (e['anotacoes']!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    _historyRow(Icons.sticky_note_2_outlined,
                                        'Anotações', e['anotacoes']!)
                                  ],
                                  if (e['obs']!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    _historyRow(
                                        Icons.notes, 'Observações', e['obs']!)
                                  ],
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => _showEditEntryDialog(
                                        context,
                                        trip,
                                        entryIndex: i,
                                        currentNotes: notesNotifier.value,
                                        onSaved: (newNotes) {
                                          notesNotifier.value = newNotes;
                                          onUpdated?.call();
                                        },
                                      ),
                                      icon: const Icon(Icons.edit, size: 14),
                                      label: const Text('Editar registro',
                                          style: TextStyle(fontSize: 12)),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.grey[600],
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _historyRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(
                      text: '\$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      );

  // ── Add annotation dialog ─────────────────────────────────────────────────
  void _showAddAnnotationDialog(BuildContext context, Trip trip,
      {required void Function(String) onSaved}) {
    final formKey = GlobalKey<FormState>();
    final adminCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();
    final anotacoesCtrl = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (_, setD) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.add_comment, color: Colors.orange),
            SizedBox(width: 8),
            Text('Nova Anotação')
          ]),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: adminCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Seu nome *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe seu nome'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: motivoCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Motivo / assunto *',
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o motivo'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: anotacoesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Anotações adicionais',
                        prefixIcon: Icon(Icons.sticky_note_2_outlined),
                        border: OutlineInputBorder(),
                        hintText: 'Detalhes extras opcionais...'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancelar')),
            ElevatedButton.icon(
              icon: saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save, size: 16),
              label: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setD(() => saving = true);
                      final novaEntrada =
                          '[Alteração por: \${adminCtrl.text.trim()}]'
                          '\nMotivo: \${motivoCtrl.text.trim()}'
                          '\${anotacoesCtrl.text.trim().isNotEmpty ? "\nAnotações: \${anotacoesCtrl.text.trim()}" : ""}';
                      final notasAtuais = trip.notes ?? '';
                      final notasAtualizadas = notasAtuais.isNotEmpty
                          ? '\$novaEntrada\n---\n\$notasAtuais'
                          : novaEntrada;
                      final success =
                          await context.read<AppProvider>().adminUpdateTrip(
                                Trip(
                                    id: trip.id,
                                    userId: trip.userId,
                                    hotelName: trip.hotelName,
                                    travelDate: trip.travelDate,
                                    checkoutDate: trip.checkoutDate,
                                    totalPrice: trip.totalPrice,
                                    status: trip.status,
                                    notes: notasAtualizadas),
                              );
                      if (context.mounted) {
                        Navigator.pop(dCtx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              success ? 'Anotação salva!' : 'Erro ao salvar.'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ));
                        if (success) onSaved(notasAtualizadas);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit entry dialog ─────────────────────────────────────────────────────
  void _showEditEntryDialog(BuildContext context, Trip trip,
      {required int entryIndex,
      required String currentNotes,
      required void Function(String) onSaved}) {
    final blocks = currentNotes.split('\n---\n');
    final reversed = blocks.reversed.toList();
    final targetIdx = reversed.length - 1 - entryIndex;
    final block = (targetIdx >= 0 && targetIdx < reversed.length)
        ? reversed[targetIdx]
        : '';

    String admin = '', motivo = '', datas = '', anotacoes = '';
    for (final line in block.split('\n')) {
      if (line.startsWith('[Alteração por: '))
        admin =
            line.replaceAll('[Alteração por: ', '').replaceAll(']', '').trim();
      else if (line.startsWith('Motivo: '))
        motivo = line.substring('Motivo: '.length).trim();
      else if (line.startsWith('Datas: '))
        datas = line.substring('Datas: '.length).trim();
      else if (line.startsWith('Anotações: '))
        anotacoes = line.substring('Anotações: '.length).trim();
    }

    final adminCtrl = TextEditingController(text: admin);
    final motivoCtrl = TextEditingController(text: motivo);
    final anotacoesCtrl = TextEditingController(text: anotacoes);
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (_, setD) => AlertDialog(
          title: const Row(children: [
            Icon(Icons.edit, color: Colors.orange),
            SizedBox(width: 8),
            Text('Editar Registro')
          ]),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: adminCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nome do responsável *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o nome'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: motivoCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Motivo *',
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o motivo'
                        : null,
                  ),
                  if (datas.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.06),
                          border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.date_range,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(datas,
                                style: const TextStyle(fontSize: 12)))
                      ]),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: anotacoesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Anotações',
                        prefixIcon: Icon(Icons.sticky_note_2_outlined),
                        border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text('Cancelar')),
            ElevatedButton.icon(
              icon: saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save, size: 16),
              label: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setD(() => saving = true);
                      final edited =
                          '[Alteração por: \${adminCtrl.text.trim()}]'
                          '\nMotivo: \${motivoCtrl.text.trim()}'
                          '\${datas.isNotEmpty ? "\nDatas: \$datas" : ""}'
                          '\${anotacoesCtrl.text.trim().isNotEmpty ? "\nAnotações: \${anotacoesCtrl.text.trim()}" : ""}';
                      reversed[targetIdx] = edited;
                      final newNotes = reversed.reversed.join('\n---\n');
                      final success =
                          await context.read<AppProvider>().adminUpdateTrip(
                                Trip(
                                    id: trip.id,
                                    userId: trip.userId,
                                    hotelName: trip.hotelName,
                                    travelDate: trip.travelDate,
                                    checkoutDate: trip.checkoutDate,
                                    totalPrice: trip.totalPrice,
                                    status: trip.status,
                                    notes: newNotes),
                              );
                      if (context.mounted) {
                        Navigator.pop(dCtx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success
                              ? 'Registro atualizado!'
                              : 'Erro ao salvar.'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ));
                        if (success) onSaved(newNotes);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit trip dialog ──────────────────────────────────────────────────────
  void _showEditTripDialog(BuildContext context, Trip trip,
      {VoidCallback? onSaved}) async {
    DateTime checkin = trip.travelDate;
    DateTime checkout =
        trip.checkoutDate ?? trip.travelDate.add(const Duration(days: 1));
    final notesController = TextEditingController(text: trip.notes);
    final adminNameController = TextEditingController();
    final changeReasonController = TextEditingController();
    final annotationsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Gerenciar Reserva'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Datas da Hospedagem',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.flight_land, color: AppColors.primary),
                    title: const Text('Check-in'),
                    subtitle: Text(_fmt.format(checkin),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: context,
                          initialDate: checkin,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100));
                      if (picked != null)
                        setDialogState(() => checkin = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.flight_takeoff,
                        color: AppColors.primary),
                    title: const Text('Check-out'),
                    subtitle: Text(_fmt.format(checkout),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: context,
                          initialDate: checkout,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100));
                      if (picked != null)
                        setDialogState(() => checkout = picked);
                    },
                  ),
                  const Divider(height: 24),
                  TextFormField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Observações da reserva',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder()),
                  ),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.assignment_ind,
                              color: Colors.orange, size: 18),
                          SizedBox(width: 6),
                          Text('Registro da Alteração (obrigatório)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 13)),
                        ]),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: adminNameController,
                          decoration: const InputDecoration(
                              labelText: 'Seu nome *',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe seu nome'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: changeReasonController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                              labelText: 'Motivo da alteração *',
                              prefixIcon: Icon(Icons.edit_note),
                              border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe o motivo'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: annotationsController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              labelText: 'Anotações adicionais',
                              prefixIcon: Icon(Icons.sticky_note_2_outlined),
                              border: OutlineInputBorder(),
                              hintText: 'Contexto extra...'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton.icon(
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Salvar'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final checkinAntes = _fmt.format(trip.travelDate);
                final checkoutAntes = _fmt.format(trip.checkoutDate ??
                    trip.travelDate.add(const Duration(days: 1)));
                final checkinDepois = _fmt.format(checkin);
                final checkoutDepois = _fmt.format(checkout);
                final datasAlteradas = (checkinAntes != checkinDepois ||
                    checkoutAntes != checkoutDepois);
                final novaEntrada =
                    '[Alteração por: \${adminNameController.text.trim()}]'
                    '\nMotivo: \${changeReasonController.text.trim()}'
                    '\${datasAlteradas ? "\nDatas: Check-in \$checkinAntes→\$checkinDepois | Check-out \$checkoutAntes→\$checkoutDepois" : ""}'
                    '\${annotationsController.text.trim().isNotEmpty ? "\nAnotações: \${annotationsController.text.trim()}" : ""}';
                final notasAntigas = notesController.text.trim();
                final registro = notasAntigas.isNotEmpty
                    ? '\$novaEntrada\n---\n\$notasAntigas'
                    : novaEntrada;
                final outerCtx = ctx;
                final provider = outerCtx.read<AppProvider>();
                final success = await provider.adminUpdateTrip(
                  Trip(
                      id: trip.id,
                      userId: trip.userId,
                      hotelName: trip.hotelName,
                      travelDate: checkin,
                      checkoutDate: checkout,
                      totalPrice: trip.totalPrice,
                      status: trip.status,
                      notes: registro),
                );
                if (outerCtx.mounted) {
                  Navigator.pop(outerCtx);
                  ScaffoldMessenger.of(outerCtx).showSnackBar(SnackBar(
                    content: Text(success
                        ? 'Reserva atualizada com sucesso!'
                        : 'Erro ao atualizar. Verifique a conexão.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                  if (success) onSaved?.call();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRequestsTab extends StatefulWidget {
  const CustomRequestsTab({super.key});

  @override
  State<CustomRequestsTab> createState() => _CustomRequestsTabState();
}

class _CustomRequestsTabState extends State<CustomRequestsTab> {
  late Future<List<CustomRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = context.read<AppProvider>().getAdminCustomRequests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CustomRequest>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('Nenhum pedido personalizado.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _requestsFuture =
                  context.read<AppProvider>().getAdminCustomRequests();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(req.userName ?? 'Usuário',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Destino: ${req.suggestedDestination}\nStatus: ${req.status.toUpperCase()}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showFullRequestDetails(context, req),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFullRequestDetails(BuildContext context, CustomRequest r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dossiê do Pedido Personalizado',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const Divider(height: 32),
              _detailItem('Cliente', r.userName),
              _detailItem('E-mail', r.userEmail),
              _detailItem('Telefone', r.userPhone),
              _detailItem('WhatsApp', r.allowWhatsapp ? 'Sim' : 'Não'),
              const Divider(),
              _detailItem('Destino Sugerido', r.suggestedDestination),
              _detailItem('Pessoas', r.peopleCount.toString()),
              _detailItem('Orçamento', r.budget),
              _detailItem('Motivo da Viagem', r.reason),
              const Divider(),
              _detailItem('Objetivos', r.objectives),
              _detailItem('Atividades', r.activities),
              _detailItem('Interesses', r.interests),
              _detailItem('Info Adicional', r.extraInfo),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            await context
                                .read<AppProvider>()
                                .updateCustomRequestStatus(r.id!, 'contatado');
                            Navigator.pop(ctx);
                            setState(() {
                              _requestsFuture = context
                                  .read<AppProvider>()
                                  .getAdminCustomRequests();
                            });
                          },
                          child: const Text('MARCAR CONTATADO'))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String? value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textGrey)),
            Text(value ?? 'Não informado',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
}

class HotelCatalogTab extends StatefulWidget {
  const HotelCatalogTab({super.key});

  @override
  State<HotelCatalogTab> createState() => _HotelCatalogTabState();
}

class _HotelCatalogTabState extends State<HotelCatalogTab> {
  final nameCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final bedroomsCtrl = TextEditingController();
  final bathroomsCtrl = TextEditingController();
  final tvsCtrl = TextEditingController();
  final amenitiesCtrl = TextEditingController();
  bool hasAC = false;
  String? base64Image;
  // Lista de tipos de quartos para o formulário de cadastro
  List<RoomType> _newRoomTypes = [];

  @override
  void initState() {
    super.initState();
    // Carrega os hotéis do banco ao abrir a aba do catálogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchHotels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Gerenciar Catálogo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Atualizar catálogo',
                onPressed: () => context.read<AppProvider>().fetchHotels(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (prov.hotels.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Nenhum destino cadastrado no banco de dados.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            )
          else
            ...prov.hotels.map((h) => Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: h.imageUrl.startsWith('data:')
                          ? Image.memory(
                              base64Decode(h.imageUrl.split(',').last),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.hotel),
                            )
                          : Image.network(
                              h.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.hotel),
                            ),
                    ),
                    title: Text(h.name),
                    subtitle: Text(
                        'R\$ ${h.pricePerNight.toStringAsFixed(2)}/noite • ${h.roomTypes.length} tipo(s) de quarto'),
                    trailing: PopupMenuButton(
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                            child: const Row(children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text("Editar")
                            ]),
                            onTap: () => _showEditHotelDialog(context, h)),
                        PopupMenuItem(
                            child: const Row(children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text("Excluir",
                                  style: TextStyle(color: Colors.red))
                            ]),
                            onTap: () => _confirmDeleteHotel(context, h)),
                      ],
                    ),
                  ),
                )),
          const Divider(height: 40),
          const Text('Cadastrar Novo Destino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 50);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setState(() => base64Image =
                    'data:image/jpeg;base64,${base64Encode(bytes)}');
              }
            },
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: base64Image != null
                      ? DecorationImage(
                          image: MemoryImage(
                              base64Decode(base64Image!.split(',').last)),
                          fit: BoxFit.cover)
                      : null),
              child: base64Image == null
                  ? const Icon(Icons.add_a_photo, size: 40)
                  : null,
            ),
          ),
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome')),
          TextField(
              controller: locCtrl,
              decoration: const InputDecoration(labelText: 'Localização')),
          TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 4),
          TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Diária (R\$)'),
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: bedroomsCtrl,
                      decoration: const InputDecoration(labelText: 'Quartos'),
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: TextField(
                      controller: bathroomsCtrl,
                      decoration: const InputDecoration(labelText: 'Banheiros'),
                      keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: tvsCtrl,
                      decoration: const InputDecoration(labelText: 'TVs'),
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: Row(children: [
                const Text('Ar-Cond.'),
                Switch(
                    value: hasAC, onChanged: (v) => setState(() => hasAC = v))
              ])),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
              controller: amenitiesCtrl,
              decoration: const InputDecoration(
                  labelText: 'Comodidades (separadas por vírgula)')),
          const SizedBox(height: 16),
          // --- Seção de Tipos de Quartos no Cadastro ---
          const Divider(),
          const Text('Tipos de Quartos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          if (_newRoomTypes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Nenhum tipo de quarto adicionado. Clique abaixo para adicionar.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            )
          else
            ..._newRoomTypes.map((rt) => ListTile(
                  dense: true,
                  title: Text(rt.name),
                  subtitle: Text(
                      '${rt.description.isNotEmpty ? rt.description : "Sem descrição"} • Mult: ${rt.priceMultiplier}x'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => setState(() => _newRoomTypes.remove(rt)),
                  ),
                )),
          TextButton.icon(
            onPressed: () {
              _showAddRoomTypeDialog(context, (newRoom) {
                setState(() => _newRoomTypes.add(newRoom));
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Tipo de Quarto'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // VALIDAÇÃO: Verificar se todos os campos obrigatórios estão preenchidos
                if (nameCtrl.text.isEmpty ||
                    locCtrl.text.isEmpty ||
                    descCtrl.text.isEmpty ||
                    priceCtrl.text.isEmpty ||
                    base64Image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'ERRO: Preencha todos os campos obrigatórios, incluindo a foto!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final success = await context.read<AppProvider>().adminAddHotel(
                    Hotel(
                        id: 0,
                        name: nameCtrl.text,
                        location: locCtrl.text,
                        description: descCtrl.text,
                        imageUrl: base64Image ?? '',
                        pricePerNight: double.tryParse(priceCtrl.text) ?? 0,
                        rating: 5.0,
                        checkinTime: '14:00',
                        checkoutTime: '12:00',
                        amenities: amenitiesCtrl.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList(),
                        bedrooms: int.tryParse(bedroomsCtrl.text) ?? 1,
                        bathrooms: int.tryParse(bathroomsCtrl.text) ?? 1,
                        tvs: int.tryParse(tvsCtrl.text) ?? 1,
                        hasAC: hasAC,
                        // Serializa os tipos de quartos adicionados
                        roomTypesJson: jsonEncode(
                            _newRoomTypes.map((r) => r.toJson()).toList())));
                if (success && mounted) {
                  setState(() {
                    nameCtrl.clear();
                    locCtrl.clear();
                    descCtrl.clear();
                    priceCtrl.clear();
                    amenitiesCtrl.clear();
                    bedroomsCtrl.clear();
                    bathroomsCtrl.clear();
                    tvsCtrl.clear();
                    base64Image = null;
                    hasAC = false;
                    _newRoomTypes = [];
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Destino cadastrado com sucesso no catálogo!')));
                  }
                } else if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Erro ao cadastrar destino. Verifique a conexão com o servidor.'),
                      backgroundColor: Colors.red));
                }
              },
              child: const Text('Cadastrar Novo Destino'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    locCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    bedroomsCtrl.dispose();
    bathroomsCtrl.dispose();
    tvsCtrl.dispose();
    amenitiesCtrl.dispose();
    super.dispose();
  }

  void _showEditHotelDialog(BuildContext context, Hotel hotel) {
    final nameCtrl = TextEditingController(text: hotel.name);
    final locCtrl = TextEditingController(text: hotel.location);
    final descCtrl = TextEditingController(text: hotel.description);
    final priceCtrl =
        TextEditingController(text: hotel.pricePerNight.toString());
    final bedroomsCtrl = TextEditingController(text: hotel.bedrooms.toString());
    final bathroomsCtrl =
        TextEditingController(text: hotel.bathrooms.toString());
    final tvsCtrl = TextEditingController(text: hotel.tvs.toString());
    final amenitiesCtrl =
        TextEditingController(text: hotel.amenities.join(', '));
    bool hAC = hotel.hasAC;
    String? b64 = hotel.imageUrl;
    List<RoomType> rTypes = List.from(hotel.roomTypes);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edição Total do Destino'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 50);
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setDialogState(() => b64 =
                          'data:image/jpeg;base64,${base64Encode(bytes)}');
                    }
                  },
                  child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          image: b64 != null
                              ? DecorationImage(
                                  image: b64!.startsWith('data')
                                      ? MemoryImage(
                                          base64Decode(b64!.split(',').last))
                                      : NetworkImage(b64!) as ImageProvider,
                                  fit: BoxFit.cover)
                              : null),
                      child:
                          b64 == null ? const Icon(Icons.add_a_photo) : null),
                ),
                TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome')),
                TextField(
                    controller: locCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Localização')),
                TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 4),
                TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Preço Base'),
                    keyboardType: TextInputType.number),
                Row(children: [
                  const Text('Quartos: '),
                  Expanded(
                      child: TextField(
                          controller: bedroomsCtrl,
                          keyboardType: TextInputType.number))
                ]),
                Row(children: [
                  const Text('Banheiros: '),
                  Expanded(
                      child: TextField(
                          controller: bathroomsCtrl,
                          keyboardType: TextInputType.number))
                ]),
                Row(children: [
                  const Text('Ar-Cond.: '),
                  Switch(
                      value: hAC,
                      onChanged: (v) => setDialogState(() => hAC = v))
                ]),
                TextField(
                    controller: amenitiesCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Comodidades (separadas por vírgula)')),
                const Divider(),
                const Text('Tipos de Quartos',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...rTypes.map((rt) => ListTile(
                      title: Text(rt.name),
                      subtitle: Text('Mult: ${rt.priceMultiplier}x'),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              setDialogState(() => rTypes.remove(rt))),
                    )),
                TextButton.icon(
                  onPressed: () {
                    _showAddRoomTypeDialog(context, (newRoom) {
                      setDialogState(() => rTypes.add(newRoom));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Novo Tipo de Quarto'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () async {
                // Validação rigorosa na edição também
                if (nameCtrl.text.isEmpty ||
                    locCtrl.text.isEmpty ||
                    priceCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Nome, Localização e Preço são obrigatórios!'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                final success = await context
                    .read<AppProvider>()
                    .adminUpdateHotel(Hotel(
                      id: hotel.id,
                      name: nameCtrl.text,
                      location: locCtrl.text,
                      description: descCtrl.text,
                      imageUrl: b64 ?? '',
                      pricePerNight: double.tryParse(priceCtrl.text) ?? 0,
                      rating: hotel.rating,
                      checkinTime: hotel.checkinTime,
                      checkoutTime: hotel.checkoutTime,
                      amenities: amenitiesCtrl.text
                          .split(',')
                          .map((e) => e.trim())
                          .toList(),
                      bedrooms: int.tryParse(bedroomsCtrl.text) ?? 1,
                      bathrooms: int.tryParse(bathroomsCtrl.text) ?? 1,
                      tvs: int.tryParse(tvsCtrl.text) ?? 1,
                      hasAC: hAC,
                      roomTypesJson:
                          jsonEncode(rTypes.map((r) => r.toJson()).toList()),
                    ));
                if (success && mounted) {
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Destino atualizado com sucesso no catálogo!')));
                } else if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Erro ao atualizar destino. Verifique a conexão com o servidor.'),
                      backgroundColor: Colors.red));
                }
              },
              child: const Text('SALVAR TODAS AS ALTERAÇÕES'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRoomTypeDialog(BuildContext context, Function(RoomType) onAdd) {
    final rNameCtrl = TextEditingController();
    final rDescCtrl = TextEditingController();
    final rMultCtrl = TextEditingController(text: '1.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo Tipo de Quarto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: rNameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nome (ex: Suíte Master)')),
            TextField(
                controller: rDescCtrl,
                decoration:
                    const InputDecoration(labelText: 'Comodidades/Descrição')),
            TextField(
                controller: rMultCtrl,
                decoration: const InputDecoration(
                    labelText: 'Multiplicador de Preço (ex: 1.5)'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (rNameCtrl.text.isNotEmpty) {
                onAdd(RoomType(
                  name: rNameCtrl.text,
                  description: rDescCtrl.text,
                  priceMultiplier: double.tryParse(rMultCtrl.text) ?? 1.0,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteHotel(BuildContext context, Hotel hotel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir'),
        content: Text('Remover ${hotel.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () async {
                await context.read<AppProvider>().deleteHotel(hotel.id);
                if (mounted) {
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Excluir')),
        ],
      ),
    );
  }
}

class FinancialPanelTab extends StatefulWidget {
  const FinancialPanelTab({super.key});

  @override
  State<FinancialPanelTab> createState() => _FinancialPanelTabState();
}

class _FinancialPanelTabState extends State<FinancialPanelTab> {
  late Future<Map<String, dynamic>> _financialFuture;
  // 0 = Faturamento Mensal, 1 = Faturamento Diário (últimos 30 dias)
  int _chartMode = 0;

  @override
  void initState() {
    super.initState();
    _financialFuture = context.read<AppProvider>().getFinancialData();
  }

  static const List<String> _meses = [
    '',
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez'
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _financialFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allData = snapshot.data ?? {};
        final mensal = allData['mensal'] as List<dynamic>? ?? [];
        final diario = allData['diario'] as List<dynamic>? ?? [];
        final porDestino = allData['porDestino'] as List<dynamic>? ?? [];
        final kpis = (allData['kpis'] as List<dynamic>?)?.firstOrNull ?? {};

        double totalFaturado = 0;
        double totalAReceber = 0;
        int totalReservas = 0;

        for (var item in mensal) {
          totalFaturado +=
              double.tryParse(item['faturamentoTotal'].toString()) ?? 0;
          totalAReceber += double.tryParse(item['aReceber'].toString()) ?? 0;
          totalReservas += int.tryParse(item['totalReservas'].toString()) ?? 0;
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _financialFuture = context.read<AppProvider>().getFinancialData();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Painel Financeiro',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf,
                          color: AppColors.primary),
                      tooltip: 'Imprimir Relatório',
                      onPressed: () => _printFinancialReport(
                          allData, totalFaturado, totalAReceber, totalReservas),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // KPIs Principais
                Row(
                  children: [
                    Expanded(
                        child: _cardFinanceiro(
                            'Faturamento',
                            'R\$ ${totalFaturado.toStringAsFixed(2)}',
                            Colors.green,
                            Icons.attach_money)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _cardFinanceiro(
                            'A Receber',
                            'R\$ ${totalAReceber.toStringAsFixed(2)}',
                            Colors.orange,
                            Icons.hourglass_empty)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _cardFinanceiro(
                            'Ticket Médio',
                            'R\$ ${(double.tryParse(kpis['ticketMedio']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
                            Colors.blue,
                            Icons.trending_up)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _cardFinanceiro(
                            'Total Reservas',
                            '$totalReservas',
                            Colors.purple,
                            Icons.confirmation_number)),
                  ],
                ),

                // ─── Seção de Faturamento com toggle Mensal/Diário ───
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _chartMode == 0
                          ? 'Faturamento Mensal'
                          : 'Faturamento Diário (30 dias)',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ToggleButtons(
                      isSelected: [_chartMode == 0, _chartMode == 1],
                      onPressed: (i) => setState(() => _chartMode = i),
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: AppColors.primary,
                      constraints:
                          const BoxConstraints(minWidth: 70, minHeight: 34),
                      children: const [
                        Text('Mensal', style: TextStyle(fontSize: 12)),
                        Text('Diário', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _chartMode == 0
                    ? _buildMensalChart(mensal)
                    : _buildDiarioChart(diario),

                // ─── Histórico Mensal (tabela) ───
                const SizedBox(height: 32),
                const Text('Histórico Mensal',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (mensal.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum dado mensal disponível.',
                        style: TextStyle(color: AppColors.textGrey)),
                  ))
                else
                  ...mensal.map((item) => Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              _meses[int.tryParse(item['mes'].toString()) ?? 0],
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                              '${_meses[int.tryParse(item['mes'].toString()) ?? 0]}/${item['ano']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item['totalReservas']} reserva(s)'),
                          trailing: Text(
                            'R\$ ${(double.tryParse(item['faturamentoTotal'].toString()) ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                      )),

                // ─── Reservas por Destino ───
                const SizedBox(height: 32),
                const Text('Reservas por Destino',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildDestinoList(porDestino),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Gráfico de linha — Faturamento Mensal com labels de mês/ano
  Widget _buildMensalChart(List<dynamic> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Nenhum dado mensal disponível.')),
      );
    }
    final spots = data.asMap().entries.map((e) {
      final val = double.tryParse(e.value['faturamentoTotal'].toString()) ?? 0;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) maxY = 100;

    return SizedBox(
      height: 260,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 8),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.2,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 56,
                  getTitlesWidget: (val, meta) {
                    if (val == 0) return const Text('');
                    return Text(
                      'R\$${(val / 1000).toStringAsFixed(0)}k',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGrey),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (val, meta) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= data.length) return const Text('');
                    final mes = int.tryParse(data[idx]['mes'].toString()) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _meses[mes],
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textGrey),
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                    radius: 5,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                  final idx = s.x.toInt();
                  if (idx < 0 || idx >= data.length) return null;
                  final mes = int.tryParse(data[idx]['mes'].toString()) ?? 0;
                  final ano = data[idx]['ano'];
                  return LineTooltipItem(
                    '${_meses[mes]}/$ano\nR\$ ${s.y.toStringAsFixed(2)}',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Gráfico de barras — Faturamento Diário (últimos 30 dias)
  Widget _buildDiarioChart(List<dynamic> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Nenhuma reserva nos últimos 30 dias.')),
      );
    }
    final fmtDia = DateFormat('dd/MM');

    double maxY = 0;
    for (var item in data) {
      final v = double.tryParse(item['faturamentoDia'].toString()) ?? 0;
      if (v > maxY) maxY = v;
    }
    if (maxY == 0) maxY = 100;

    return SizedBox(
      height: 260,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 8),
        child: BarChart(
          BarChartData(
            maxY: maxY * 1.2,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 56,
                  getTitlesWidget: (val, meta) {
                    if (val == 0) return const Text('');
                    return Text(
                      'R\$${(val / 1000).toStringAsFixed(0)}k',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGrey),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: (data.length / 6).ceilToDouble().clamp(1, 999),
                  getTitlesWidget: (val, meta) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= data.length) return const Text('');
                    try {
                      final dia = DateTime.parse(data[idx]['dia'].toString());
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          fmtDia.format(dia),
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textGrey),
                        ),
                      );
                    } catch (_) {
                      return const Text('');
                    }
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
            barGroups: data.asMap().entries.map((e) {
              final val =
                  double.tryParse(e.value['faturamentoDia'].toString()) ?? 0;
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: val,
                    color: AppColors.primary,
                    width: data.length > 20 ? 8 : 14,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex < 0 || groupIndex >= data.length) return null;
                  String diaStr = '';
                  try {
                    final dia =
                        DateTime.parse(data[groupIndex]['dia'].toString());
                    diaStr = DateFormat('dd/MM/yyyy').format(dia);
                  } catch (_) {
                    diaStr = data[groupIndex]['dia'].toString();
                  }
                  final reservas = data[groupIndex]['totalReservas'];
                  return BarTooltipItem(
                    '$diaStr\n$reservas reserva(s)\nR\$ ${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Lista de destinos mais reservados com nomes visíveis
  Widget _buildDestinoList(List<dynamic> data) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhuma reserva por destino disponível.',
              style: TextStyle(color: AppColors.textGrey)),
        ),
      );
    }
    final colors = [
      AppColors.primary,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
      Colors.pink,
    ];
    final maxTotal = data.isNotEmpty
        ? (double.tryParse(data.first['total'].toString()) ?? 1)
        : 1.0;

    return Column(
      children: data.asMap().entries.map((e) {
        final item = e.value;
        final destino = item['destino']?.toString() ?? 'Desconhecido';
        final total = int.tryParse(item['total'].toString()) ?? 0;
        final faturamento =
            double.tryParse(item['faturamento'].toString()) ?? 0;
        final color = colors[e.key % colors.length];
        final pct = maxTotal > 0 ? (total / maxTotal) : 0.0;

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(
                        '${e.key + 1}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        destino,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$total reserva(s)',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Faturamento: R\$ ${faturamento.toStringAsFixed(2)}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _printFinancialReport(Map<String, dynamic> allData,
      double totalFaturado, double totalAReceber, int totalReservas) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final mensal = allData['mensal'] as List<dynamic>? ?? [];
    final porDestino = allData['porDestino'] as List<dynamic>? ?? [];
    final kpis = (allData['kpis'] as List<dynamic>?)?.firstOrNull ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Relatorio Financeiro Executivo - Partiu Destino',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text(fmt.format(now),
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 15),
            pw.Text('Indicadores de Performance (KPIs)',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Metrica', 'Valor'],
              data: [
                [
                  'Faturamento Total',
                  'R\$ ${totalFaturado.toStringAsFixed(2)}'
                ],
                ['Total a Receber', 'R\$ ${totalAReceber.toStringAsFixed(2)}'],
                ['Total de Reservas', '$totalReservas'],
                [
                  'Ticket Medio por Reserva',
                  'R\$ ${(double.tryParse(kpis['ticketMedio']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}'
                ],
              ],
            ),
            pw.SizedBox(height: 25),
            pw.Text('Desempenho por Destino',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Destino', 'Qtd Reservas', 'Faturamento'],
              data: porDestino
                  .map((item) => [
                        '${item['destino']}',
                        '${item['total']}',
                        'R\$ ${(double.tryParse(item['faturamento'].toString()) ?? 0).toStringAsFixed(2)}'
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 25),
            pw.Text('Historico Mensal',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Mes/Ano', 'Reservas', 'Faturamento'],
              data: mensal
                  .map((item) => [
                        '${_meses[int.tryParse(item['mes'].toString()) ?? 0]}/${item['ano']}',
                        '${item['totalReservas']}',
                        'R\$ ${(double.tryParse(item['faturamentoTotal'].toString()) ?? 0).toStringAsFixed(2)}'
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 40),
            pw.Divider(),
            pw.Center(
                child: pw.Text(
                    'Documento gerado pelo Sistema de Gestao Partiu Destino',
                    style: const pw.TextStyle(fontSize: 8))),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'relatorio_executivo_${now.millisecondsSinceEpoch}.pdf',
    );
  }

  Widget _cardFinanceiro(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ===== FLIGHTS MANAGEMENT TAB =====


class FlightFinancialPanelTab extends StatefulWidget {
  const FlightFinancialPanelTab({super.key});

  @override
  State<FlightFinancialPanelTab> createState() => _FlightFinancialPanelTabState();
}

class _FlightFinancialPanelTabState extends State<FlightFinancialPanelTab> {
  late Future<Map<String, dynamic>> _financialFuture;

  @override
  void initState() {
    super.initState();
    _financialFuture = context.read<AppProvider>().getFlightFinancialData();
  }

  static const List<String> _meses = [
    '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _financialFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allData = snapshot.data ?? {};
        final mensal = allData['mensal'] as List<dynamic>? ?? [];
        final porDestino = allData['porDestino'] as List<dynamic>? ?? [];
        final kpis = (allData['kpis'] as List<dynamic>?)?.firstOrNull ?? {};

        double totalFaturado = 0;
        double totalAReceber = 0;
        int totalPassagens = 0;

        for (final item in mensal) {
          totalFaturado += double.tryParse(item['faturamentoTotal'].toString()) ?? 0;
          totalAReceber += double.tryParse(item['aReceber'].toString()) ?? 0;
          totalPassagens += int.tryParse(item['totalPassagens'].toString()) ?? 0;
        }

        final ticketMedio = double.tryParse(kpis['ticketMedio']?.toString() ?? '0') ?? 0;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _financialFuture = context.read<AppProvider>().getFlightFinancialData();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumo Financeiro das Passagens',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Acompanhe quanto está sendo vendido em passagens aéreas, valores pendentes, ticket médio e destinos com mais vendas.',
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _flightFinanceCard('Vendido', 'R\$ ${totalFaturado.toStringAsFixed(2)}', Colors.green, Icons.attach_money)),
                    const SizedBox(width: 12),
                    Expanded(child: _flightFinanceCard('A Receber', 'R\$ ${totalAReceber.toStringAsFixed(2)}', Colors.orange, Icons.hourglass_empty)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _flightFinanceCard('Ticket Médio', 'R\$ ${ticketMedio.toStringAsFixed(2)}', Colors.blue, Icons.trending_up)),
                    const SizedBox(width: 12),
                    Expanded(child: _flightFinanceCard('Total Passagens', '$totalPassagens', Colors.purple, Icons.airplane_ticket_rounded)),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('Histórico Mensal de Passagens',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (mensal.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: Text('Nenhum dado financeiro de passagens disponível.')),
                    ),
                  )
                else
                  ...mensal.map((item) {
                    final mesIndex = int.tryParse(item['mes'].toString()) ?? 0;
                    final valor = double.tryParse(item['faturamentoTotal'].toString()) ?? 0;
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            mesIndex >= 0 && mesIndex < _meses.length ? _meses[mesIndex] : '-',
                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text('${mesIndex >= 0 && mesIndex < _meses.length ? _meses[mesIndex] : '-'} / ${item['ano']}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item['totalPassagens']} passagem(ns) vendida(s) ou registradas'),
                        trailing: Text(
                          'R\$ ${valor.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 30),
                const Text('Vendas por Destino',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (porDestino.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: Text('Nenhum destino com venda registrado.')),
                    ),
                  )
                else
                  ...porDestino.map((item) {
                    final valor = double.tryParse(item['faturamento'].toString()) ?? 0;
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEAF3F8),
                          child: Icon(Icons.location_on_rounded, color: AppColors.primary),
                        ),
                        title: Text(item['destino']?.toString() ?? 'Destino não informado',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item['total']} passagem(ns)'),
                        trailing: Text('R\$ ${valor.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _flightFinanceCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 14),
          Text(title, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FlightReservationsAdminTab extends StatefulWidget {
  const FlightReservationsAdminTab({super.key});

  @override
  State<FlightReservationsAdminTab> createState() =>
      _FlightReservationsAdminTabState();
}

class _FlightReservationsAdminTabState extends State<FlightReservationsAdminTab> {
  late Future<List<FlightReservation>> _reservationsFuture;
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _reservationsFuture =
        context.read<AppProvider>().getAdminFlightReservations();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlightReservation>>(
      future: _reservationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reservations = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: () async => setState(_reload),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Passagens compradas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Aqui o admin visualiza as passagens dos usuários e altera a reserva individual, sem editar o voo global do catálogo.',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              if (reservations.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('Nenhuma passagem comprada.')),
                  ),
                )
              else
                ...reservations.map((reservation) =>
                    _buildReservationCard(context, reservation)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReservationCard(
      BuildContext context, FlightReservation reservation) {
    final passengerNames = reservation.passengers.isEmpty
        ? 'Nenhum passageiro informado'
        : reservation.passengers.map((p) => p.name).join(', ');
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${reservation.id} • ${reservation.origin ?? '-'} → ${reservation.destination ?? '-'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _statusChip(reservation.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Comprador: ${reservation.userName ?? 'Usuário ${reservation.userId}'} • ${reservation.userEmail ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Divider(height: 22),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _info(Icons.flight_takeoff, 'Embarque',
                    reservation.departureDate != null
                        ? _fmt.format(reservation.departureDate!)
                        : '-'),
                _info(Icons.flight_land, 'Chegada',
                    reservation.arrivalDate != null
                        ? _fmt.format(reservation.arrivalDate!)
                        : '-'),
                _info(Icons.keyboard_return, 'Volta',
                    reservation.returnDate != null
                        ? _fmt.format(reservation.returnDate!)
                        : '-'),
                _info(Icons.airplanemode_active, 'Aeronave',
                    reservation.aircraftModel ?? '-'),
                _info(Icons.event_seat, 'Assentos',
                    reservation.seats.isEmpty ? '-' : reservation.seats.join(', ')),
                _info(Icons.attach_money, 'Total',
                    'R\$ ${reservation.totalPrice.toStringAsFixed(2)}'),
                _info(Icons.people, 'Passageiros', passengerNames),
                _info(Icons.schedule, 'Compra', _fmt.format(reservation.createdAt)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.history),
                  label: const Text('Histórico'),
                  onPressed: () => _showHistoryDialog(context, reservation),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar passagem'),
                  onPressed: () => _showEditReservationDialog(context, reservation),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'confirmado'
        ? Colors.green
        : status == 'cancelado'
            ? Colors.red
            : status == 'concluido'
                ? Colors.blueGrey
                : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return SizedBox(
      width: 230,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime? current) async {
    final initial = current ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  double? _parseMoney(String value) {
    final clean = value.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (clean.contains(',')) {
      return double.tryParse(clean.replaceAll('.', '').replaceAll(',', '.'));
    }
    return double.tryParse(clean);
  }

  void _showEditReservationDialog(
      BuildContext context, FlightReservation reservation) {
    final originCtrl = TextEditingController(text: reservation.origin ?? '');
    final destinationCtrl =
        TextEditingController(text: reservation.destination ?? '');
    final aircraftCtrl =
        TextEditingController(text: reservation.aircraftModel ?? '');
    final totalCtrl = TextEditingController(
        text: reservation.totalPrice.toStringAsFixed(2).replaceAll('.', ','));
    final seatsCtrl = TextEditingController(text: reservation.seats.join(', '));
    final passengersCtrl = TextEditingController(
        text: jsonEncode(reservation.passengers.map((p) => p.toJson()).toList()));
    DateTime? departureDate = reservation.departureDate;
    DateTime? arrivalDate = reservation.arrivalDate;
    DateTime? returnDate = reservation.returnDate;
    String status = reservation.status;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Editar passagem comprada'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reserva #${reservation.id} de ${reservation.userName ?? 'usuário ${reservation.userId}'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: originCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Origem', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: destinationCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Destino', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dateTile(dialogContext, 'Embarque', departureDate,
                      (value) => setDialogState(() => departureDate = value)),
                  _dateTile(dialogContext, 'Chegada', arrivalDate,
                      (value) => setDialogState(() => arrivalDate = value)),
                  _dateTile(dialogContext, 'Volta', returnDate,
                      (value) => setDialogState(() => returnDate = value)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: aircraftCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Aeronave', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: totalCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: 'Valor total', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: seatsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Assentos separados por vírgula',
                      hintText: 'Ex: 1A, 1B',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(
                        labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                      DropdownMenuItem(value: 'confirmado', child: Text('Confirmado')),
                      DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                      DropdownMenuItem(value: 'concluido', child: Text('Concluído')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => status = value ?? 'pendente'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passengersCtrl,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Passageiros em JSON',
                      helperText:
                          'Permite alterar nome, CPF/documento, telefone, nascimento e assento do passageiro.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.35)),
                    ),
                    child: const Text(
                      'Ao salvar, será aberta uma confirmação obrigatória para registrar quem alterou, o motivo e a observação no histórico.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar')),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Continuar'),
              onPressed: () async {
                final total = _parseMoney(totalCtrl.text);
                if (originCtrl.text.trim().isEmpty ||
                    destinationCtrl.text.trim().isEmpty ||
                    aircraftCtrl.text.trim().isEmpty ||
                    departureDate == null ||
                    total == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Preencha origem, destino, embarque, aeronave e valor.'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                List<Passenger> passengers;
                try {
                  final decoded = jsonDecode(passengersCtrl.text);
                  passengers = (decoded as List)
                      .map((p) => Passenger.fromJson(Map<String, dynamic>.from(p)))
                      .toList();
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('JSON de passageiros inválido.'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                final seats = seatsCtrl.text
                    .split(',')
                    .map((s) => s.trim().toUpperCase())
                    .where((s) => s.isNotEmpty)
                    .toList();
                if (seats.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Informe ao menos um assento.'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                final updated = FlightReservation(
                  id: reservation.id,
                  flightId: reservation.flightId,
                  userId: reservation.userId,
                  totalPrice: total,
                  passengers: passengers,
                  status: status,
                  createdAt: reservation.createdAt,
                  userName: reservation.userName,
                  userEmail: reservation.userEmail,
                  origin: originCtrl.text.trim(),
                  destination: destinationCtrl.text.trim(),
                  departureDate: departureDate,
                  arrivalDate: arrivalDate,
                  returnDate: returnDate,
                  aircraftModel: aircraftCtrl.text.trim(),
                  seats: seats,
                );

                final success = await _showChangeConfirmationDialog(
                    context, updated);
                if (success && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  setState(_reload);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(BuildContext context, String label, DateTime? value,
      ValueChanged<DateTime?> onSelected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_month, color: AppColors.primary),
      title: Text(label),
      subtitle: Text(value != null ? _fmt.format(value) : 'Não informado'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => onSelected(null),
            ),
          const Icon(Icons.edit_calendar),
        ],
      ),
      onTap: () async {
        final picked = await _pickDateTime(context, value);
        if (picked != null) onSelected(picked);
      },
    );
  }

  Future<bool> _showChangeConfirmationDialog(
      BuildContext context, FlightReservation updated) async {
    final adminNameCtrl = TextEditingController();
    final adminEmailCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar alteração da passagem'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Para manter o histórico, informe quem está fazendo a alteração e o motivo.',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: adminNameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nome de quem alterou *',
                        border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Informe o nome'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: adminEmailCtrl,
                    decoration: const InputDecoration(
                        labelText: 'E-mail ou identificação *',
                        border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Informe a identificação'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Motivo da alteração *',
                        border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Informe o motivo'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: notesCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Observação/anotação',
                        border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmar e salvar'),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider = context.read<AppProvider>();
              final success = await provider.updateAdminFlightReservation(
                updated,
                adminName: adminNameCtrl.text.trim(),
                adminEmail: adminEmailCtrl.text.trim(),
                reason: reasonCtrl.text.trim(),
                notes: notesCtrl.text.trim(),
              );
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, success);
              }
            },
          ),
        ],
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result == true
            ? 'Passagem atualizada e histórico registrado.'
            : 'A passagem não foi alterada.'),
        backgroundColor: result == true ? Colors.green : Colors.orange,
      ));
    }
    return result == true;
  }

  void _showHistoryDialog(BuildContext context, FlightReservation reservation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Histórico da passagem #${reservation.id}'),
        content: SizedBox(
          width: 620,
          child: FutureBuilder<List<FlightReservationHistory>>(
            future: context
                .read<AppProvider>()
                .getFlightReservationHistory(reservation.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()));
              }
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma alteração registrada para esta passagem.'),
                );
              }
              return SizedBox(
                height: 420,
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fmt.format(item.createdAt),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Text('Alterado por: ${item.adminName} (${item.adminEmail})'),
                            Text('Motivo: ${item.reason}'),
                            if (item.notes.isNotEmpty) Text('Observação: ${item.notes}'),
                            const Divider(),
                            Text(_changesSummary(item.oldData, item.newData),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar')),
        ],
      ),
    );
  }

  String _changesSummary(
      Map<String, dynamic> oldData, Map<String, dynamic> newData) {
    final fields = {
      'origin': 'Origem',
      'destination': 'Destino',
      'departure_date': 'Embarque',
      'arrival_date': 'Chegada',
      'return_date': 'Volta',
      'aircraft_model': 'Aeronave',
      'total_price': 'Valor',
      'status': 'Status',
      'seats': 'Assentos',
    };
    final changes = <String>[];
    fields.forEach((key, label) {
      final oldValue = oldData[key]?.toString() ?? '';
      final newValue = newData[key]?.toString() ?? '';
      if (oldValue != newValue) {
        changes.add('$label: $oldValue → $newValue');
      }
    });
    return changes.isEmpty
        ? 'Alteração registrada. Dados completos salvos no histórico.'
        : changes.join('\n');
  }
}

class FlightsManagementTab extends StatefulWidget {
  const FlightsManagementTab({super.key});

  @override
  State<FlightsManagementTab> createState() => _FlightsManagementTabState();
}

class _FlightsManagementTabState extends State<FlightsManagementTab> {
  late Future<List<Flight>> _flightsFuture;
  final _fmtFull = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _refreshFlights();
  }

  void _refreshFlights() {
    _flightsFuture = context.read<AppProvider>().getAdminFlights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Flight>>(
        future: _flightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final flights = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              setState(_refreshFlights);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Gestão de Voos',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showFlightFormDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Voo'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cadastre aqui exatamente as informações que aparecem no catálogo: origem, destino, horários de ida e volta, aeronave, preço, assentos e status.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 16),
                if (flights.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('Nenhum voo cadastrado.')),
                    ),
                  )
                else
                  ...flights.map((flight) => _buildFlightCard(context, flight)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlightCard(BuildContext context, Flight flight) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${flight.flightCode} • ${flight.origin} → ${flight.destination}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID do voo: ${flight.id}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                _statusChip(flight.status),
              ],
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _infoItem(Icons.flight_takeoff, 'Embarque ida',
                    _fmtFull.format(flight.departureDate)),
                _infoItem(
                    Icons.flight_land,
                    'Chegada ida',
                    flight.arrivalDate != null
                        ? _fmtFull.format(flight.arrivalDate!)
                        : 'Não informado'),
                _infoItem(
                    Icons.keyboard_return,
                    'Embarque volta',
                    flight.returnDate != null
                        ? _fmtFull.format(flight.returnDate!)
                        : 'Não informado'),
                _infoItem(Icons.airplanemode_active, 'Aeronave',
                    flight.aircraftModel),
                _infoItem(Icons.event_seat, 'Assentos',
                    '${flight.totalSeats} (${flight.totalRows} filas x ${flight.seatsPerRow} por fila)'),
                _infoItem(Icons.attach_money, 'Preço',
                    'R\$ ${flight.pricePerSeat.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      _showFlightFormDialog(context, flight: flight),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar tudo'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDeleteFlight(context, flight),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Deletar',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status == 'ativo';
    final color = isActive
        ? Colors.green
        : status == 'cancelado'
            ? Colors.red
            : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return SizedBox(
      width: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime? current) async {
    final now = DateTime.now();
    final initial = current ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  double? _parseMoney(String value) {
    final clean = value.trim().replaceAll('R\$', '').replaceAll(' ', '');
    if (clean.contains(',')) {
      return double.tryParse(clean.replaceAll('.', '').replaceAll(',', '.'));
    }
    return double.tryParse(clean);
  }

  int? _parsePositiveInt(String value) {
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) return null;
    return number;
  }

  Widget _dateButton({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onSelected,
    bool requiredField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: () async {
          final picked = await _pickDateTime(context, value);
          if (picked != null) onSelected(picked);
        },
        icon: const Icon(Icons.calendar_month),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value == null
                ? '$label${requiredField ? ' *' : ''}'
                : '$label: ${_fmtFull.format(value)}',
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  void _showFlightFormDialog(BuildContext context, {Flight? flight}) {
    final isEdit = flight != null;
    final originCtrl = TextEditingController(text: flight?.origin ?? '');
    final destCtrl = TextEditingController(text: flight?.destination ?? '');
    final priceCtrl = TextEditingController(
        text: flight != null
            ? flight.pricePerSeat.toStringAsFixed(2).replaceAll('.', ',')
            : '');
    final aircraftCtrl =
        TextEditingController(text: flight?.aircraftModel ?? 'Airbus A320');
    final rowsCtrl = TextEditingController(text: '${flight?.totalRows ?? 30}');
    final seatsCtrl =
        TextEditingController(text: '${flight?.seatsPerRow ?? 6}');

    DateTime? departureDate = flight?.departureDate;
    DateTime? arrivalDate = flight?.arrivalDate;
    DateTime? returnDate = flight?.returnDate;
    String selectedStatus = flight?.status ?? 'ativo';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editar Voo Completo' : 'Novo Voo Completo'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações do catálogo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: originCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Origem / aeroporto *',
                      hintText: 'Ex: São Paulo (GRU)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: destCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Destino / aeroporto *',
                      hintText: 'Ex: Rio de Janeiro (GIG)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dateButton(
                    context: dialogContext,
                    label: 'Data e horário do embarque na ida',
                    value: departureDate,
                    requiredField: true,
                    onSelected: (value) =>
                        setDialogState(() => departureDate = value),
                  ),
                  _dateButton(
                    context: dialogContext,
                    label: 'Data e horário de chegada na ida',
                    value: arrivalDate,
                    onSelected: (value) =>
                        setDialogState(() => arrivalDate = value),
                  ),
                  _dateButton(
                    context: dialogContext,
                    label: 'Data e horário do embarque na volta',
                    value: returnDate,
                    requiredField: true,
                    onSelected: (value) =>
                        setDialogState(() => returnDate = value),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Preço por passagem *',
                            hintText: '350,00',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: aircraftCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Aeronave *',
                            hintText: 'Airbus A320',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: rowsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de filas *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: seatsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Assentos por fila *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status do voo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'ativo',
                          child: Text('Ativo / Disponível no catálogo')),
                      DropdownMenuItem(
                          value: 'cancelado', child: Text('Cancelado')),
                      DropdownMenuItem(
                          value: 'concluido', child: Text('Concluído')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => selectedStatus = value ?? 'ativo'),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Prévia: ${originCtrl.text.isEmpty ? 'Origem' : originCtrl.text} → ${destCtrl.text.isEmpty ? 'Destino' : destCtrl.text} | ${aircraftCtrl.text.isEmpty ? 'Aeronave' : aircraftCtrl.text}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar')),
            ElevatedButton.icon(
              icon: Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? 'Salvar alterações' : 'Cadastrar voo'),
              onPressed: () async {
                final price = _parseMoney(priceCtrl.text);
                final rows = _parsePositiveInt(rowsCtrl.text);
                final seatsPerRow = _parsePositiveInt(seatsCtrl.text);

                if (originCtrl.text.trim().isEmpty ||
                    destCtrl.text.trim().isEmpty ||
                    aircraftCtrl.text.trim().isEmpty ||
                    departureDate == null ||
                    returnDate == null ||
                    price == null ||
                    rows == null ||
                    seatsPerRow == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Preencha origem, destino, ida, volta, preço, aeronave e assentos corretamente.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final provider = context.read<AppProvider>();
                final success = isEdit
                    ? await provider.updateFlight(
                        flight!.id,
                        originCtrl.text.trim(),
                        destCtrl.text.trim(),
                        departureDate!,
                        arrivalDate,
                        returnDate,
                        price,
                        aircraftCtrl.text.trim(),
                        rows,
                        seatsPerRow,
                        selectedStatus,
                      )
                    : await provider.createFlight(
                        originCtrl.text.trim(),
                        destCtrl.text.trim(),
                        departureDate!,
                        arrivalDate,
                        returnDate,
                        price,
                        aircraftCtrl.text.trim(),
                        rows,
                        seatsPerRow,
                        selectedStatus,
                      );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted) {
                  if (success) {
                    setState(_refreshFlights);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit
                            ? 'Voo atualizado com sucesso!'
                            : 'Voo cadastrado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Erro ao salvar voo. Confira se o backend está ligado e se o banco foi atualizado.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteFlight(BuildContext context, Flight flight) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar Voo'),
        content: Text(
            'Tem certeza que deseja deletar o voo ${flight.origin} → ${flight.destination}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final success =
                  await context.read<AppProvider>().deleteFlight(flight.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted && success) {
                setState(_refreshFlights);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voo deletado com sucesso!')),
                );
              }
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
