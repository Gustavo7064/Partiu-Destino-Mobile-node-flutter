# ✈️ Partiu Destino - Viagens e Hospedagens

Aplicativo mobile de agência de turismo desenvolvido em Flutter com backend em Node.js e banco de dados MySQL.

---

## 🚀 Tecnologias Utilizadas

- **Flutter & Dart** (Frontend)
- **Node.js & Express** (Backend API)
- **MySQL** (Banco de Dados)
- **Dio** (Comunicação HTTP)
- **Provider** (Gerenciamento de Estado)

---

## 🛠️ Como Configurar e Rodar

### 1. Banco de Dados
- Importe o script `backend/database.sql` no seu MySQL.

### 2. Backend (Node.js)
```bash
cd backend
npm install
npm start
```
*O servidor iniciará em http://localhost:3000. Mantenha este terminal aberto!*

### 3. Flutter (O Aplicativo)
**Não rode `flutter test`**, pois isso apenas testa o código. Para abrir o aplicativo, use:
```bash
flutter pub get
flutter run
```
Se estiver no VS Code, abra o arquivo `lib/main.dart` e aperte **F5**.

---

## 📁 Estrutura Atualizada
- `lib/`: Código fonte do aplicativo Flutter.
- `backend/`: API em Node.js (não precisa de Apache).
- `assets/`: Logotipos e imagens do projeto.
- `DEBUG_GUIDE.md`: Instruções detalhadas para resolver problemas de conexão.

---
Desenvolvido com ❤️ para o projeto Partiu Destino.
