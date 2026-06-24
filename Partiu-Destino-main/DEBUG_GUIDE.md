# 🛠️ Guia de Debug e Execução - Partiu Destino

Este guia ajudará você a rodar o projeto e resolver problemas comuns de conexão.

## 1. Configurando o Banco de Dados (MySQL)
1. Abra o seu gerenciador de MySQL (ex: MySQL Workbench ou phpMyAdmin).
2. Crie um banco chamado `partiu_destino`.
3. Selecione o banco e execute o código que está em `backend/database.sql`.
4. **IMPORTANTE**: No arquivo `backend/server.js`, verifique as linhas 24-29. Se o seu MySQL tiver senha, coloque-a lá. Se o usuário não for `root`, troque também.

## 2. Como resolver "Erro ao conectar ao servidor"
Este erro no Flutter significa que o App não achou a API.
1. **API Desligada**: Verifique se você rodou `npm start` dentro da pasta `backend`. O terminal deve mostrar "Servidor Rodando".
2. **IP Incorreto**: Se estiver usando celular físico, você DEVE trocar `localhost` pelo seu IP (ex: 192.168.x.x) no arquivo `lib/data/app_provider.dart`.
3. **Firewall**: O Windows pode bloquear a conexão. Tente desativar o Firewall rapidinho para testar.

## 2. Rodando o Backend (Node.js)
Não é necessário Apache! Siga estes passos:
1. Abra o terminal na pasta `backend`.
2. Instale as dependências (apenas na primeira vez):
   ```bash
   npm install
   ```
3. Inicie o servidor:
   ```bash
   npm start
   ```
O servidor rodará em `http://localhost:3000`.

## 3. Rodando o Flutter
Para que o Flutter consiga "enxergar" o backend, configuramos o endereço automaticamente no arquivo `lib/data/app_provider.dart`.

### Se estiver usando Emulador Android:
- O endereço configurado é `http://10.0.2.2:3000`. Isso é necessário porque o Android trata o `localhost` como o próprio emulador, não o seu computador.

### Se estiver usando Celular Físico:
- O celular e o computador devem estar no mesmo Wi-Fi.
- Você deve trocar `localhost` pelo **IP do seu computador** (ex: `192.168.1.5`) no arquivo `lib/data/app_provider.dart`.

## 4. Como Debugar (VS Code)
1. Pressione `F5` no VS Code.
2. Selecione a opção **"App + Backend"** no menu de Debug. Isso iniciará o servidor Node e o App Flutter ao mesmo tempo.
3. Se estiver no navegador, o App abrirá em `http://localhost:8080`.
4. O erro `ERR_CONNECTION_REFUSED` acontece se você tentar acessar o site antes de rodar o comando `flutter run`.

## 5. Scripts de Atalho
- **Windows**: Clique duas vezes em `start_project.bat` para abrir tudo automaticamente.
- **Linux/Mac**: Rode `sh start_project.sh`.

---
**Dica**: Se o erro for "Connection Refused" no Android, verifique se o seu Firewall não está bloqueando a porta 3000.
