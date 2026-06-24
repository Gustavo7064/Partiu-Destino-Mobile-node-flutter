#!/bin/bash
echo "Iniciando Projeto Partiu Destino..."

# Iniciar backend em segundo plano
cd backend && npm install && npm start &

echo "Aguardando backend iniciar..."
sleep 5

# Voltar para a raiz e rodar o flutter
cd ..
flutter run -d chrome --web-port 8080
