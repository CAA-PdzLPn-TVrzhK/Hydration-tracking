# Hydration Tracking Application

A comprehensive cross-platform hydration tracking application built with Go microservices backend and Flutter frontend.

## 🏗️ Architecture Overview

### Backend (Go Microservices)
- **Auth Service** (Port 8081): JWT-based authentication and user management
- **Hydration Service** (Port 8082): Water intake logging and statistics
- **Notification Service** (Port 8083): Reminders and notifications with gRPC
- **PostgreSQL**: Primary database with proper schema design
- **Redis**: Caching and session management
- **Nginx**: API gateway and load balancer

### Frontend (Flutter)
- **Cross-platform**: Mobile (iOS/Android) + Web
- **State Management**: Riverpod for reactive state management
- **Offline Support**: SQLite for local data persistence
- **Theme Support**: Light and dark mode
- **Responsive Design**: Custom widgets and Material Design 3

## 🚀 Features

### Backend Features
- [x] Go-based microservices architecture (3 services)
- [x] RESTful API with Swagger documentation
- [x] PostgreSQL database with proper schema design
- [x] JWT-based authentication and authorization
- [x] Comprehensive unit and integration tests
- [x] Docker containerization
- [x] CI/CD pipeline with GitHub Actions
- [x] Environment configuration management
- [x] Rate limiting and security headers

### Frontend Features
- [x] Flutter-based cross-platform application
- [x] Responsive UI design with custom widgets
- [x] State management with Riverpod
- [x] Offline data persistence with SQLite
- [x] Unit and widget tests
- [x] Light and dark mode support
- [x] Local notifications and reminders
- [x] Beautiful charts and visualizations

### DevOps Features
- [x] Docker Compose for all services
- [x] CI/CD pipeline implementation
- [x] Environment configuration management
- [x] GitHub Pages ready for documentation

## 📋 Prerequisites

- Docker and Docker Compose
- Go 1.21+
- Flutter 3.16.0+
- PostgreSQL 15+
- Redis 7+

## 🛠️ Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/hydration-tracking.git
cd hydration-tracking
```

### 2. Backend Setup

#### Install Go Dependencies
```bash
cd backend
go mod download
```

#### Set up Environment Variables
```bash
cp config.env.example config.env
# Edit config.env with your configuration
```

#### Run Database Migrations
```bash
# Using Docker Compose (recommended)
docker-compose up postgres -d
# Wait for PostgreSQL to be ready, then run migrations
```

#### Run Services Locally
```bash
# Auth Service
go run services/auth/main.go

# Hydration Service
go run services/hydration/main.go

# Notification Service
go run services/notification/main.go
```

### 3. Frontend Setup

#### Install Flutter Dependencies
```bash
cd frontend
flutter pub get
```

#### Run Flutter App
```bash
# For Web
flutter run -d chrome

# For Mobile
flutter run -d android
flutter run -d ios
```

### 4. Docker Setup (Recommended)

#### Start All Services
```bash
docker-compose up -d
```

This will start:
- PostgreSQL database
- Redis cache
- Auth service (Port 8081)
- Hydration service (Port 8082)
- Notification service (Port 8083)
- Nginx API gateway (Port 80)
- Flutter web app (Port 3000)

#### Access Services
- **Web App**: http://localhost:3000
- **API Gateway**: http://localhost
- **Swagger Docs**: http://localhost/swagger/
- **Auth Service**: http://localhost:8081
- **Hydration Service**: http://localhost:8082
- **Notification Service**: http://localhost:8083

## 🧪 Testing

### Backend Tests
```bash
cd backend
go test -v ./services/auth
go test -v ./services/hydration
go test -v ./services/notification
```

### Frontend Tests
```bash
cd frontend
flutter test
flutter analyze
```

## 📚 API Documentation

### Authentication Endpoints
- `POST /api/v1/register` - Register new user
- `POST /api/v1/login` - User login
- `GET /api/v1/profile` - Get user profile (protected)

### Hydration Endpoints
- `POST /api/v1/entries` - Log water intake (protected)
- `GET /api/v1/entries` - Get user entries (protected)
- `GET /api/v1/stats` - Get hydration statistics (protected)
- `PUT /api/v1/goal` - Update daily goal (protected)

### Notification Endpoints
- `GET /api/v1/notifications` - Get user notifications (protected)
- `POST /api/v1/notifications` - Create notification (protected)
- `PUT /api/v1/notifications/{id}/read` - Mark as read (protected)
- `GET /api/v1/reminder-settings` - Get reminder settings (protected)
- `PUT /api/v1/reminder-settings` - Update reminder settings (protected)

## 🗄️ Database Schema

### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Hydration Entries Table
```sql
CREATE TABLE hydration_entries (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    amount INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    type VARCHAR(50) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### User Goals Table
```sql
CREATE TABLE user_goals (
    user_id UUID PRIMARY KEY,
    daily_goal INTEGER DEFAULT 2000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Notifications Table
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## 🔧 Configuration

### Environment Variables
Key environment variables for each service:

#### Auth Service
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `JWT_SECRET`, `JWT_EXPIRY_HOURS`
- `AUTH_SERVICE_PORT`

#### Hydration Service
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `HYDRATION_SERVICE_PORT`

#### Notification Service
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `NOTIFICATION_SERVICE_PORT`, `GRPC_PORT`

## 🚀 Deployment

### Production Deployment
1. Set up a production PostgreSQL database
2. Configure environment variables for production
3. Build and push Docker images
4. Deploy using Docker Compose or Kubernetes

### GitHub Pages
The project is configured for GitHub Pages deployment. The Flutter web build will be automatically deployed to GitHub Pages.

## 📱 Mobile App Features

### Core Features
- **Water Intake Logging**: Quick add buttons for common amounts
- **Daily Goals**: Set and track daily hydration goals
- **Statistics**: View daily, weekly, and monthly progress
- **Charts**: Visual representation of hydration data
- **Reminders**: Customizable notification reminders
- **Offline Support**: Works without internet connection

### UI/UX Features
- **Responsive Design**: Adapts to different screen sizes
- **Theme Support**: Light and dark mode
- **Custom Widgets**: Beautiful, modern UI components
- **Animations**: Smooth transitions and micro-interactions
- **Accessibility**: Screen reader support and high contrast

## 🔒 Security Features

- JWT-based authentication
- Password hashing (bcrypt in production)
- Rate limiting
- CORS configuration
- Input validation
- SQL injection prevention
- XSS protection headers

## 📊 Monitoring & Logging

- Structured logging with different levels
- Health check endpoints
- Metrics collection (Prometheus ready)
- Error tracking and reporting

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Check the API documentation at `/swagger/`
- Review the test files for usage examples

## 🎯 Roadmap

- [ ] Push notifications for mobile
- [ ] Social features (friends, challenges)
- [ ] Integration with health apps
- [ ] Advanced analytics and insights
- [ ] Multi-language support
- [ ] Voice commands
- [ ] Apple Watch/Android Wear integration

---
