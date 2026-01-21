#!/bin/bash

# FabricFlow - Quick Setup Script
# This script automates the setup process for FabricFlow

set -e  # Exit on error

echo "🚀 FabricFlow Setup Script"
echo "=========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print colored message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

MISSING_DEPS=()

if ! command_exists python3; then
    MISSING_DEPS+=("python3")
fi

if ! command_exists psql; then
    MISSING_DEPS+=("postgresql")
fi

if ! command_exists redis-cli; then
    MISSING_DEPS+=("redis")
fi

if ! command_exists flutter; then
    MISSING_DEPS+=("flutter")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    print_error "Missing dependencies: ${MISSING_DEPS[*]}"
    print_warning "Please install missing dependencies and run this script again"
    exit 1
fi

print_success "All prerequisites are installed"
echo ""

# Setup Backend
echo "Setting up Backend..."
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    print_warning "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
print_warning "Installing Python dependencies..."
pip install -r requirements.txt > /dev/null 2>&1
print_success "Python dependencies installed"

# Setup environment file
if [ ! -f ".env" ]; then
    print_warning "Creating .env file..."
    cp .env.example .env
    
    # Generate secret key
    SECRET_KEY=$(openssl rand -hex 32)
    
    # Update .env with generated secret key
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/your-super-secret-key-change-this-in-production/$SECRET_KEY/" .env
    else
        # Linux
        sed -i "s/your-super-secret-key-change-this-in-production/$SECRET_KEY/" .env
    fi
    
    print_success ".env file created with generated SECRET_KEY"
    print_warning "Please update other settings in .env file (database URL, API keys, etc.)"
else
    print_success ".env file already exists"
fi

cd ..

# Setup Frontend
echo ""
echo "Setting up Frontend..."
cd frontend

print_warning "Installing Flutter dependencies..."
flutter pub get > /dev/null 2>&1
print_success "Flutter dependencies installed"

cd ..

# Database setup prompt
echo ""
echo "Database Setup"
echo "=============="
read -p "Do you want to create the PostgreSQL database now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter database name (default: fabricflow_db): " DB_NAME
    DB_NAME=${DB_NAME:-fabricflow_db}
    
    read -p "Enter database user (default: fabricflow_user): " DB_USER
    DB_USER=${DB_USER:-fabricflow_user}
    
    read -sp "Enter database password: " DB_PASSWORD
    echo
    
    # Create database and user
    print_warning "Creating database..."
    
    createdb $DB_NAME || print_warning "Database might already exist"
    
    psql postgres -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" || print_warning "User might already exist"
    psql postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    
    print_success "Database setup complete"
    
    # Update DATABASE_URL in .env
    cd backend
    DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=$DATABASE_URL|" .env
    else
        sed -i "s|DATABASE_URL=.*|DATABASE_URL=$DATABASE_URL|" .env
    fi
    
    cd ..
fi

# Run migrations
echo ""
read -p "Do you want to run database migrations now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd backend
    source venv/bin/activate
    
    print_warning "Running migrations..."
    alembic upgrade head
    print_success "Migrations applied"
    
    cd ..
fi

# Summary
echo ""
echo "================================================"
echo "✨ Setup Complete! ✨"
echo "================================================"
echo ""
echo "Next Steps:"
echo ""
echo "1. Backend:"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   uvicorn app.main:app --reload"
echo "   → http://localhost:8000"
echo "   → API docs: http://localhost:8000/api/docs"
echo ""
echo "2. Frontend:"
echo "   cd frontend"
echo "   flutter run -d chrome"
echo ""
echo "3. With Docker:"
echo "   docker-compose up"
echo ""
echo "📚 For more information, see SETUP.md"
echo ""
print_success "Happy coding! 🎉"
