#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Konfiguracja Open WebUI z Traefik ===${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker nie jest zainstalowany. Zainstaluj Docker przed kontynuowaniem.${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose nie jest zainstalowany. Zainstaluj Docker Compose przed kontynuowaniem.${NC}"
    exit 1
fi

echo -e "${GREEN}Konfiguracja zmiennych środowiskowych${NC}"

read -p "Podaj klucz API OpenAI: " openai_key
read -p "Podaj domenę dla Open WebUI (np. webui.twojadomena.pl): " domain

sed -i "s|OPENAI_API_KEY=your_secret_key|OPENAI_API_KEY=$openai_key|g" .env
sed -i "s|OPEN_WEBUI_DOMAIN=webui.twojadomena.pl|OPEN_WEBUI_DOMAIN=$domain|g" .env

echo
echo -e "${YELLOW}Czy chcesz zainstalować Ollama wraz z Open WebUI? (t/n)${NC}"
read use_ollama

if [[ "$use_ollama" == "t" || "$use_ollama" == "T" ]]; then
    echo -e "${GREEN}Konfiguracja z Ollama${NC}"
    sed -i 's|# - OLLAMA_BASE_URL=http://ollama:11434|- OLLAMA_BASE_URL=http://ollama:11434|g' docker-compose.yml
    sed -i 's|# depends_on:|depends_on:|g' docker-compose.yml
    sed -i 's|#   - ollama|  - ollama|g' docker-compose.yml
    sed -i 's|# ollama:|ollama:|g' docker-compose.yml
    sed -i 's|#   container_name: ollama|  container_name: ollama|g' docker-compose.yml
    sed -i 's|#   image: ollama/ollama:latest|  image: ollama/ollama:latest|g' docker-compose.yml
    sed -i 's|#   volumes:|  volumes:|g' docker-compose.yml
    sed -i 's|#     - ollama:/root/.ollama|    - ollama:/root/.ollama|g' docker-compose.yml
    sed -i 's|#   restart: always|  restart: always|g' docker-compose.yml
    sed -i 's|#   networks:|  networks:|g' docker-compose.yml
    sed -i 's|#     - private|    - private|g' docker-compose.yml
    sed -i 's|# ollama:|ollama:|g' docker-compose.yml
fi

echo
echo -e "${GREEN}Uruchamianie kontenerów Docker...${NC}"
docker compose up -d

echo
echo -e "${BLUE}=== Instalacja zakończona ===${NC}"
echo -e "${GREEN}Open WebUI jest teraz dostępny pod adresem: ${YELLOW}https://$domain${NC}"
echo -e "${GREEN}Aby sprawdzić logi, użyj: ${YELLOW}docker logs open-webui${NC}"
echo

if ! docker network ls | grep -q traefik_webgateway; then
    echo -e "${YELLOW}UWAGA: Sieć 'traefik_webgateway' nie istnieje. Upewnij się, że masz poprawnie skonfigurowany Traefik.${NC}"
fi 