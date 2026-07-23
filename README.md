# Partiu Destino 🛫🏨

O **Partiu Destino** é um aplicativo web/mobile completo desenvolvido em Flutter, com backend em Node.js e banco de dados MySQL. A plataforma atua como um marketplace de viagens, oferecendo um catálogo de hotéis, reserva de passagens aéreas e um sistema de planejamento de viagens personalizadas. O projeto também conta com um robusto painel administrativo para gestão de usuários, reservas e relatórios financeiros.

![Partiu Destino Logo](partiuDestinoJPE.jpg)

## 📋 Índice

- [Funcionalidades](#funcionalidades)
- [Arquitetura do Projeto](#arquitetura-do-projeto)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Pré-requisitos](#pré-requisitos)
- [Como Executar Localmente](#como-executar-localmente)
- [Configuração do Banco de Dados](#configuração-do-banco-de-dados)
- [Estrutura de Pastas](#estrutura-de-pastas)
- [Contribuição](#contribuição)

## ✨ Funcionalidades

### Para Usuários
- **Catálogo de Hospedagens**: Busca e filtragem de hotéis por localização, número de quartos e banheiros.
- **Reserva de Voos**: Seleção de voos com mapa interativo de assentos e gestão de passageiros.
- **Viagens Personalizadas**: Fluxo em etapas para solicitar um roteiro de viagem sob medida, baseado no orçamento e preferências do usuário.
- **Favoritos e Avaliações**: Salvar hotéis favoritos e deixar avaliações após a estadia.
- **Pagamentos**: Integração com Mercado Pago (checkout transparente e PIX) para realização de reservas.
- **Perfil do Usuário**: Gerenciamento de informações pessoais e histórico de viagens.

### Para Administradores
- **Dashboard Financeiro**: Relatórios detalhados de receitas e desempenho de vendas.
- **Gestão de Catálogo**: Cadastro, atualização e exclusão de hotéis e rotas de voos.
- **Gestão de Usuários**: Controle de acesso e permissões de usuários registrados.
- **Aprovação de Viagens**: Análise e aprovação/rejeição de solicitações de viagens personalizadas.

## 🏗️ Arquitetura do Projeto

O projeto adota uma arquitetura client-server:

1. **Frontend (Flutter)**: Aplicativo construído com Flutter, compatível com Web e Mobile, utilizando o `Provider` para gerenciamento de estado e `Dio` para requisições HTTP.
2. **Backend (Node.js/Express)**: API RESTful que gerencia a lógica de negócios, autenticação (com `bcryptjs`) e validações.
3. **Banco de Dados (MySQL)**: Armazenamento persistente de usuários, hotéis, voos, reservas e dados financeiros. O backend realiza uma sincronização automática do schema na inicialização.

## 🛠️ Tecnologias Utilizadas

| Componente | Tecnologias |
| :--- | :--- |
| **Frontend** | Flutter, Dart, Provider, Dio, Material Design 3 |
| **Backend** | Node.js, Express, `body-parser`, `cors` |
| **Banco de Dados** | MySQL (via `mysql2`) |
| **Autenticação** | bcryptjs |
| **Pagamentos** | Mercado Pago (API) |
| **Outros** | PDF Generation, Gráficos (`fl_chart`) |

## 💻 Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas em sua máquina:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.0.0 ou superior)
- [Node.js](https://nodejs.org/) (versão 16 ou superior)
- [MySQL Server](https://dev.mysql.com/downloads/mysql/) (com acesso via usuário `root`)

## 🚀 Como Executar Localmente

O projeto fornece um script facilitador para executar o backend e o frontend simultaneamente.

### 1. Configurar o Banco de Dados
Crie um banco de dados MySQL chamado `partiu_destino`. O backend tentará criar as tabelas necessárias automaticamente na primeira execução, mas certifique-se de que as credenciais de acesso no arquivo `/backend/server.js` correspondam à sua configuração local.

### 2. Executar o Script Automático
Abra o terminal na raiz do projeto (`Partiu-Destino-main`) e execute:

```bash
chmod +x start_project.sh
./start_project.sh
```

Este script fará o seguinte:
1. Acessará a pasta `backend`, instalará as dependências (`npm install`) e iniciará o servidor na porta `3000`.
2. Após 5 segundos, voltará para a raiz do projeto e iniciará o aplicativo Flutter Web na porta `8080`.

### 3. Execução Manual (Alternativa)

Se preferir executar as partes separadamente:

**Backend:**
```bash
cd backend
npm install
npm start
```
*O servidor API ficará rodando em `http://localhost:3000`.*

**Frontend:**
```bash
flutter pub get
flutter run -d chrome --web-port 8080
```
*O aplicativo web ficará acessível em `http://localhost:8080`.*

## 📁 Estrutura de Pastas

```text
Partiu-Destino-main/
├── assets/images/       # Imagens estáticas e logotipos
├── backend/             # API Node.js/Express
│   ├── node_modules/
│   ├── package.json
│   └── server.js        # Arquivo principal do backend e rotas
├── lib/                 # Código fonte Flutter
│   ├── core/constants/  # Constantes (cores, temas)
│   ├── data/            # Modelos (Models) e Provider de estado
│   ├── presentation/    # Telas (Screens) e Widgets da UI
│   ├── services/        # Serviços externos (ex: Mercado Pago)
│   └── main.dart        # Ponto de entrada do app
├── web/                 # Arquivos de configuração para a versão Web
├── pubspec.yaml         # Dependências do Flutter
└── start_project.sh     # Script de inicialização
```

## 🤝 Contribuição

Este projeto foi desenvolvido como solução completa para marketplace de viagens. Pull requests são bem-vindos! Para grandes mudanças, por favor, abra uma issue primeiro para discutir o que você gostaria de mudar.

---

**Nota**: As credenciais de banco de dados e chaves de API estão expostas no código-fonte para fins de desenvolvimento local. Em um ambiente de produção, é fundamental utilizar variáveis de ambiente (como `.env`) para proteger informações sensíveis.
