#!/bin/bash
# ============================================
# Home Gym Project: Environment Bootstrap Script
# Author: Abir
# ============================================

echo "🏋️ Bootstrapping development environment..."

# --- COLORS ---
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

# --- SYSTEM DEPENDENCIES ---
SYS_PKGS=("git" "curl" "python3" "python3-pip" "python3-venv" "virtualbox-guest-additions-iso" "build-essential" "libpq-dev")
echo -e "${YELLOW}Checking and installing system dependencies...${RESET}"

for pkg in "${SYS_PKGS[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo -e "${GREEN}$pkg already installed.${RESET}"
  else
    echo -e "${YELLOW}Installing $pkg...${RESET}"
    sudo apt install -y "$pkg"
  fi
done

# --- PYTHON VIRTUAL ENVIRONMENT ---
PROJECT_DIR="$HOME/Projects"
ENV_DIR="$PROJECT_DIR/venv"

if [ ! -d "$ENV_DIR" ]; then
  echo -e "${YELLOW}Creating virtual environment...${RESET}"
  python3 -m venv "$ENV_DIR"
fi

source "$ENV_DIR/bin/activate"

# --- PYTHON DEPENDENCIES ---
PY_PKGS=("flask" "fastapi" "uvicorn" "psycopg2-binary" "SQLAlchemy" "alembic" "jinja2" "itsdangerous" "Werkzeug" "blinker" "anyio" "pydantic" "typing-inspection")
echo -e "${YELLOW}Checking and installing Python dependencies...${RESET}"

for pkg in "${PY_PKGS[@]}"; do
  if python3 -c "import $pkg" &>/dev/null; then
    echo -e "${GREEN}$pkg already installed.${RESET}"
  else
    echo -e "${YELLOW}Installing $pkg...${RESET}"
    pip install "$pkg"
  fi
done

# --- ENVIRONMENT CHECK ---
echo -e "${YELLOW}Verifying setup...${RESET}"
python3 - <<'EOF'
import sys
try:
    import flask, fastapi, psycopg2, alembic, jinja2
    print("✅ All required Python modules are working!")
except ImportError as e:
    print(f"❌ Missing module: {e.name}")
    sys.exit(1)
EOF

# --- GIT CONFIGURATION PROMPT ---
read -p "Enter your Git username: " GIT_USER
read -p "Enter your Git email: " GIT_EMAIL

git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"

echo -e "${YELLOW}Testing Git configuration...${RESET}"
git config --list | grep "user."

# --- DIRECTORY STRUCTURE ---
echo -e "${YELLOW}Ensuring project directory structure...${RESET}"
mkdir -p "$PROJECT_DIR/home_gym_app"/{backend,frontend,database,scripts,tests}

echo -e "${GREEN}✅ Environment setup complete!${RESET}"
