#!/bin/bash

set -e

TOTAL=5
STEP=0
BOLD="\e[1m"
RESET="\e[0m"

step() {
  STEP=$((STEP + 1))
  local COLOR="${COLORS[$((STEP - 1))]}"
  local LINE="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  echo ""
  echo -e "\e[38;5;105m${BOLD}${LINE}${RESET}"
  echo -e "\e[38;5;105m${BOLD}  STEP ${STEP}/${TOTAL}  ${RESET}${BOLD}$1${RESET}"
  echo -e "\e[38;5;105m${BOLD}${LINE}${RESET}"
  echo ""
}

echo -e "\n\e[1m  Statamic Setup\e[0m\n"

step "Creating .env file if not exist"
if [ ! -f .env ]; then
  cp .env.example .env
fi

step "Installing PHP dependencies"
docker run --rm -v $(pwd):/app -w /app composer install --optimize-autoloader --no-dev --no-scripts

step "Compiling frontend assets"
docker run --rm -v $(pwd):/app -w /app node:20-alpine sh -c "npm install && npm run build"

step "Bringing up Docker containers"
docker compose up -d

step "Generating Application key"
docker compose exec cms php artisan key:generate

step "Publishing Control Panel assets"
docker compose exec cms php artisan vendor:publish --tag=statamic-cp --force

echo ""
echo -e "\e[38;5;83m\e[1m  ✓ Setup complete!\e[0m  Visit http://localhost:8000"
echo ""
echo -ne "\033]0;✓ setup.sh — done\007"
