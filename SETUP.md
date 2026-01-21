# FabricFlow - Quick Start Guide

## 🚀 Getting Started

This guide will help you set up and run FabricFlow on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Python 3.11+** - [Download](https://www.python.org/downloads/)
- **PostgreSQL 16** - [Download](https://www.postgresql.org/download/)
- **Redis** - [Download](https://redis.io/download)
- **Flutter 3.16+** - [Install Guide](https://flutter.dev/docs/get-started/install)
- **Docker & Docker Compose** (optional) - [Install](https://docs.docker.com/get-docker/)
- **Git** - [Download](https://git-scm.com/downloads)

## 📦 Installation

### Option 1: Docker Setup (Recommended for Quick Start)

```bash
# Clone the repository
git clone https://github.com/ihariganesh/ProFabric.git
cd ProFabric

# Start all services
docker-compose up --build

# Backend will be available at http://localhost:8000
# API docs at http://localhost:8000/api/docs
```

### Option 2: Manual Setup

#### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create PostgreSQL database
createdb fabricflow_db

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
nano .env  # or use any text editor

# Required variables to set:
# - DATABASE_URL
# - SECRET_KEY (generate with: openssl rand -hex 32)
# - API keys for AI services (optional for testing)

# Initialize database with Alembic
alembic upgrade head

# Start the development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The backend API will be available at `http://localhost:8000`

#### 2. Frontend Setup

```bash
# Open a new terminal
cd frontend

# Get Flutter dependencies
flutter pub get

# Run the app (choose your platform)

# For Web:
flutter run -d chrome

# For Android:
flutter run -d android

# For iOS (Mac only):
flutter run -d ios

# To build release versions:
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## 🗄️ Database Setup

### Create Database and User

```sql
-- Connect to PostgreSQL
psql postgres

-- Create database
CREATE DATABASE fabricflow_db;

-- Create user
CREATE USER fabricflow_user WITH PASSWORD 'your_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE fabricflow_db TO fabricflow_user;

-- Connect to the database
\c fabricflow_db

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO fabricflow_user;
```

### Run Migrations

```bash
cd backend

# Create initial migration (if needed)
alembic revision --autogenerate -m "Initial migration"

# Apply migrations
alembic upgrade head

# To rollback
alembic downgrade -1
```

## 🔑 API Keys Setup

FabricFlow uses AI services for design generation. You'll need API keys for:

### 1. Google Gemini API (Recommended)
```bash
# Get your API key from: https://makersuite.google.com/app/apikey
# Add to .env:
GEMINI_API_KEY=your_gemini_api_key_here
```

### 2. Stable Diffusion API (Alternative)
```bash
# Get your API key from: https://platform.stability.ai/
# Add to .env:
STABLE_DIFFUSION_API_KEY=your_sd_api_key_here
```

### 3. AWS S3 (For Image Storage)
```bash
# Get credentials from AWS Console
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
S3_BUCKET_NAME=fabricflow-assets
```

## 🧪 Testing the Application

### Test Backend API

```bash
# Health check
curl http://localhost:8000/api/v1/health

# API documentation
open http://localhost:8000/api/docs

# Create a test user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "role": "Buyer",
    "name": "Test User",
    "email": "test@example.com",
    "password": "testpassword123"
  }'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=testpassword123"
```

### Run Backend Tests

```bash
cd backend

# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html

# Run specific test file
pytest tests/test_auth.py -v
```

### Run Frontend Tests

```bash
cd frontend

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Mobile Development Setup

### Android Setup

1. Install Android Studio
2. Set up Android SDK
3. Create an emulator or connect a physical device
4. Run: `flutter run`

### iOS Setup (Mac only)

1. Install Xcode from App Store
2. Install CocoaPods: `sudo gem install cocoapods`
3. Run: `cd ios && pod install`
4. Run: `flutter run`

## 🔧 Common Issues & Solutions

### Issue: Database connection failed

**Solution:**
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql

# Check connection
psql -U fabricflow_user -d fabricflow_db -h localhost
```

### Issue: Redis connection failed

**Solution:**
```bash
# Check if Redis is running
redis-cli ping

# Start Redis
sudo systemctl start redis

# Or with Docker:
docker run -d -p 6379:6379 redis:7-alpine
```

### Issue: Flutter dependencies error

**Solution:**
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# If still issues, remove pubspec.lock
rm pubspec.lock
flutter pub get
```

### Issue: Port already in use

**Solution:**
```bash
# Find process using port 8000
lsof -i :8000

# Kill the process
kill -9 <PID>

# Or run on different port
uvicorn app.main:app --port 8001
```

## 🌐 Environment Variables Reference

### Backend (.env)

```env
# Database
DATABASE_URL=postgresql://fabricflow_user:password@localhost:5432/fabricflow_db

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY=your-generated-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# AI APIs
GEMINI_API_KEY=your-key-here
STABLE_DIFFUSION_API_KEY=your-key-here

# AWS
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
S3_BUCKET_NAME=fabricflow-assets

# App Settings
DEBUG=True
CORS_ORIGINS=["http://localhost:3000"]

# Optimization Weights
OPTIMIZATION_COST_WEIGHT=0.5
OPTIMIZATION_SPEED_WEIGHT=0.3
OPTIMIZATION_QUALITY_WEIGHT=0.2
```

### Frontend (api_constants.dart)

```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
// Change to your production URL when deploying
```

## 📊 Seeding Test Data

```bash
cd backend

# Create a seed script
python scripts/seed_data.py

# This will create:
# - Sample users (Buyers, Vendors, Factories, Logistics)
# - Sample products/services
# - Sample orders
```

## 🚢 Production Deployment

### Backend Deployment (AWS/GCP/Azure)

```bash
# Set production environment variables
export DEBUG=False
export DATABASE_URL=your-production-db-url

# Run with gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000

# Or with Docker
docker build -t fabricflow-backend .
docker run -p 8000:8000 fabricflow-backend
```

### Frontend Deployment

```bash
# Build for production
flutter build web --release

# Deploy to hosting (Firebase, Netlify, Vercel)
# Or build mobile apps
flutter build apk --release
flutter build ios --release
```

## 📚 Next Steps

1. **Explore API Documentation**: Visit `http://localhost:8000/api/docs`
2. **Review Database Schema**: Check `docs/database-schema.md`
3. **Understand Architecture**: Read through `README.md`
4. **Customize UI**: Modify Flutter theme in `lib/core/theme/app_theme.dart`
5. **Add Features**: Check `CONTRIBUTING.md` for guidelines

## 💡 Development Tips

### Hot Reload

**Backend:**
```bash
# Auto-reload on code changes
uvicorn app.main:app --reload
```

**Frontend:**
```bash
# Flutter has hot reload built-in
# Press 'r' in terminal to hot reload
# Press 'R' for hot restart
```

### Debugging

**Backend:**
```python
# Add breakpoints in your IDE (VS Code, PyCharm)
# Or use Python debugger
import pdb; pdb.set_trace()
```

**Frontend:**
```dart
// Use Flutter DevTools
flutter run --debug

// Add debug prints
debugPrint('Debug message');
```

## 🆘 Getting Help

- **GitHub Issues**: [Create an issue](https://github.com/ihariganesh/ProFabric/issues)
- **Documentation**: Check the `docs/` directory
- **API Reference**: `http://localhost:8000/api/docs`

## 📝 Useful Commands

```bash
# Backend
python -m pytest                    # Run tests
black app/                          # Format code
flake8 app/                         # Lint code
alembic revision -m "message"       # Create migration
alembic upgrade head                # Apply migrations

# Frontend
flutter analyze                     # Analyze code
flutter format .                    # Format code
flutter build                       # Build app
flutter doctor                      # Check setup

# Docker
docker-compose up                   # Start services
docker-compose down                 # Stop services
docker-compose logs -f backend      # View logs
docker-compose exec backend bash    # Enter container
```

---

**Happy Coding! 🎉**

For more information, visit the [full documentation](./docs/)
