# FabricFlow - AI-Powered Supply Chain & Manufacturing Platform

![FabricFlow Logo](https://img.shields.io/badge/FabricFlow-v1.0-12aee2?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3.11-blue?style=for-the-badge&logo=python)
![Flutter](https://img.shields.io/badge/Flutter-3.16-02569B?style=for-the-badge&logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.109-009688?style=for-the-badge&logo=fastapi)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql)

## 🎯 Overview

FabricFlow is a comprehensive AI-powered platform that connects fabric buyers with a multi-stage supply chain ecosystem, including raw material vendors, production units, and logistics providers. The platform leverages AI for fabric design generation, intelligent supply chain optimization, and real-time tracking.

## ✨ Key Features

### 🎨 Smart Order Module (Buyer View)
- **AI-Powered Design Studio**: Generate fabric designs using text prompts via Stable Diffusion/Gemini API
- **Interactive 3D Preview**: Visualize designs on 3D fabric models
- **Automatic BOM Calculator**: Calculate raw material requirements based on order specifications
- **Smart Form**: Input quantity, material type, thread count, and GSM

### 🧠 Optimization Engine
- **Multi-Factor Analysis**: Optimize for Cost, Speed, and Quality
- **Intelligent Routing**: Construct optimal supply chain paths
- **Vendor Matching**: Automatically find the best vendors and manufacturers
- **Real-Time Scoring**: Dynamic scoring algorithm for vendor selection

### 💼 Bidding & Offer System
- **Automated Proposals**: System generates package deals for buyers
- **Vendor Dashboard**: Accept/reject automated requests
- **Multi-Party Coordination**: Seamless communication between all stakeholders

### 📍 Real-Time Operations & Tracking
- **Live GPS Tracking**: Monitor shipments in real-time
- **Production Status Updates**: Track manufacturing stages (Knitting, Dyeing, Finishing, QC)
- **Interactive Timeline**: Visual representation of order lifecycle
- **WebSocket Integration**: Instant status updates

### 💳 Payments & Communication
- **Escrow-Style Gateway**: Secure milestone-based payments
- **In-App Chat**: Direct communication between buyers and vendors
- **Automated Notifications**: Smart notification center for all updates

## 🏗️ Architecture

```
FabricFlow/
├── backend/              # FastAPI Backend
│   ├── app/
│   │   ├── api/         # API endpoints
│   │   ├── core/        # Configuration & security
│   │   ├── models/      # SQLAlchemy models
│   │   ├── schemas/     # Pydantic schemas
│   │   ├── services/    # Business logic
│   │   └── utils/       # Utilities
│   ├── alembic/         # Database migrations
│   ├── tests/           # Backend tests
│   └── requirements.txt
├── frontend/            # Flutter Application
│   ├── lib/
│   │   ├── core/        # Core utilities
│   │   ├── features/    # Feature modules
│   │   ├── shared/      # Shared widgets
│   │   └── main.dart
│   └── pubspec.yaml
├── docs/                # Documentation
└── stitch app design/   # UI/UX Reference
```

## 🛠️ Tech Stack

### Backend
- **Framework**: FastAPI (Python 3.11+)
- **Database**: PostgreSQL 16
- **ORM**: SQLAlchemy
- **Migration**: Alembic
- **Real-Time**: WebSockets (Socket.io)
- **AI Integration**: 
  - Google Gemini Pro Vision API
  - Stable Diffusion API
- **Caching**: Redis
- **Task Queue**: Celery

### Frontend
- **Framework**: Flutter 3.16+
- **State Management**: Riverpod
- **Networking**: Dio
- **Real-Time**: Socket.io Client
- **Local Storage**: Hive
- **Maps**: Google Maps Flutter

### DevOps
- **Containerization**: Docker & Docker Compose
- **CI/CD**: GitHub Actions
- **Cloud**: AWS / Google Cloud Platform
- **Monitoring**: Prometheus + Grafana

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- PostgreSQL 16
- Flutter 3.16+
- Redis
- Node.js 18+ (for some dev tools)

### Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Linux/Mac

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your configuration

# Run database migrations
alembic upgrade head

# Start the development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Get Flutter dependencies
flutter pub get

# Run the app
flutter run

# Or build for specific platform
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

### Docker Setup

```bash
# Build and run all services
docker-compose up --build

# Backend will be available at http://localhost:8000
# Frontend web at http://localhost:3000
```

## 📊 Database Schema

The platform uses a relational PostgreSQL database with the following key tables:

- **users**: Multi-role user authentication (Buyer, MaterialVendor, Factory, Logistics)
- **products_services**: Vendor offerings and capabilities
- **orders**: Parent order from buyers
- **bill_of_materials**: Auto-calculated material requirements
- **sub_orders**: Split orders for different vendors/tasks
- **shipments**: Logistics tracking with GPS coordinates

See [Database Schema Documentation](./docs/database-schema.md) for details.

## 🔌 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh access token

### Orders
- `POST /api/v1/orders` - Create new order
- `GET /api/v1/orders/{id}` - Get order details
- `GET /api/v1/orders/my-orders` - Get user's orders

### AI Design
- `POST /api/v1/ai/generate-design` - Generate fabric design from prompt
- `POST /api/v1/ai/calculate-bom` - Calculate Bill of Materials

### Optimization
- `POST /api/v1/optimize/find-vendors` - Find optimal vendors
- `POST /api/v1/optimize/route` - Calculate optimal supply chain route

### Tracking
- `GET /api/v1/tracking/order/{id}` - Get real-time order tracking
- `WS /api/v1/ws/tracking/{order_id}` - WebSocket for live updates

See [API Documentation](./docs/api-reference.md) for complete reference.

## 🎨 UI Design System

FabricFlow uses a custom design system based on the provided UI mockups:

### Color Palette
- **Primary**: `#12aee2` (Cyan Blue)
- **Background Dark**: `#101d22`
- **Background Light**: `#f6f8f8`
- **Glass Effect**: `rgba(255, 255, 255, 0.03)` with backdrop blur

### Typography
- **Font Family**: Inter
- **Weights**: 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold)

### Components
- Glass-morphism cards
- Material Design 3 icons
- Animated transitions
- Gradient overlays
- Interactive 3D previews

## 🧪 Testing

```bash
# Backend tests
cd backend
pytest tests/ -v

# Frontend tests
cd frontend
flutter test

# Integration tests
pytest tests/integration/ -v
```

## 📈 Performance Optimization

- **Database Indexing**: Optimized indexes on frequently queried fields
- **Caching**: Redis caching for vendor queries and BOM calculations
- **Lazy Loading**: Pagination for large datasets
- **Image Optimization**: CDN delivery for AI-generated designs
- **WebSocket Pooling**: Efficient real-time connection management

## 🔒 Security Features

- JWT-based authentication with refresh tokens
- Role-based access control (RBAC)
- Password hashing with bcrypt
- SQL injection prevention via ORM
- CORS configuration
- Rate limiting on API endpoints
- Encrypted escrow payment handling

## 🌍 Deployment

### Production Checklist
- [ ] Set up PostgreSQL with proper connection pooling
- [ ] Configure Redis for caching
- [ ] Set up CDN for static assets
- [ ] Configure environment variables
- [ ] Enable SSL/TLS
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy
- [ ] Set up CI/CD pipeline

### Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/fabricflow

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# AI APIs
GEMINI_API_KEY=your-gemini-api-key
STABLE_DIFFUSION_API_KEY=your-sd-api-key

# AWS/GCP
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
S3_BUCKET_NAME=fabricflow-assets
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see [LICENSE](./LICENSE) file for details.

## 👥 Authors

- **Hari Ganesh** - *Initial work* - [@ihariganesh](https://github.com/ihariganesh)

## 🙏 Acknowledgments

- UI/UX designs inspired by the stitch app design collection
- Material Design 3 guidelines
- Flutter and FastAPI communities

## 📞 Contact & Support

- **GitHub Issues**: [Create an issue](https://github.com/ihariganesh/ProFabric/issues)
- **Email**: support@fabricflow.com
- **Documentation**: [Full Documentation](./docs/)

---

Built with ❤️ for the fabric manufacturing industry
