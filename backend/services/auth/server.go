package auth

// @SecurityDefinitions.apikey BearerAuth
// @In header
// @Name Authorization

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"hydration-tracking/services/auth/docs"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	_ "github.com/lib/pq"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// Database interface for testing
type Database interface {
	Exec(query string, args ...interface{}) (sql.Result, error)
	QueryRow(query string, args ...interface{}) *sql.Row
}

type User struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required" example:"john_doe"`
	Password string `json:"password" binding:"required" example:"password123"`
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required" example:"john_doe"`
	Email    string `json:"email" binding:"required,email" example:"john@example.com"`
	Password string `json:"password" binding:"required,min=6" example:"password123"`
}

type RegisterResponse struct {
	Message string `json:"message" example:"User registered successfully"`
	UserID  string `json:"user_id" example:"550e8400-e29b-41d4-a716-446655440000"`
}

type LoginResponse struct {
	Token string   `json:"token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
	User  UserInfo `json:"user"`
}

type UserInfo struct {
	ID       string `json:"id" example:"550e8400-e29b-41d4-a716-446655440000"`
	Username string `json:"username" example:"john_doe"`
	Email    string `json:"email" example:"john@example.com"`
}

type ErrorResponse struct {
	Error string `json:"error" example:"Invalid credentials"`
}

type Claims struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	jwt.RegisteredClaims
}

var (
	db     Database
	secret = []byte("your-secret-key")
)

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func InitDB() {
	// Load environment variables
	dbHost := getEnv("DB_HOST", "localhost")
	dbPort := getEnv("DB_PORT", "5432")
	dbName := getEnv("DB_NAME", "hydration_tracking")
	dbUser := getEnv("DB_USER", "postgres")
	dbPassword := getEnv("DB_PASSWORD", "password")
	dbSSLMode := getEnv("DB_SSL_MODE", "disable")

	connStr := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s",
		dbUser, dbPassword, dbHost, dbPort, dbName, dbSSLMode)

	var err error
	sqlDB, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	db = sqlDB

	// Create users table if not exists
	createTable := `
	CREATE TABLE IF NOT EXISTS users (
		id UUID PRIMARY KEY,
		username VARCHAR(50) UNIQUE NOT NULL,
		email VARCHAR(100) UNIQUE NOT NULL,
		password VARCHAR(255) NOT NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);`

	_, err = db.Exec(createTable)
	if err != nil {
		log.Fatal(err)
	}
}

// Register godoc
// @Summary      Register new user / Регистрация пользователя
// @Description  Register a new user / Зарегистрировать нового пользователя
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        data  body  RegisterRequest  true  "User data / Данные пользователя"
// @Success      201   {object}  RegisterResponse
// @Failure      400   {object}  ErrorResponse
// @Router       /api/v1/register [post]
func register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	userID := uuid.New().String()
	hashedPassword := hashPassword(req.Password) // In production, use bcrypt

	_, err := db.Exec("INSERT INTO users (id, username, email, password) VALUES ($1, $2, $3, $4)",
		userID, req.Username, req.Email, hashedPassword)
	if err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: "Username or email already exists"})
		return
	}

	c.JSON(http.StatusCreated, RegisterResponse{Message: "User registered successfully", UserID: userID})
}

// Login godoc
// @Summary      Login user / Вход пользователя
// @Description  Login user and get JWT / Войти и получить JWT
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        data  body  LoginRequest  true  "Login data / Данные для входа"
// @Success      200   {object}  LoginResponse
// @Failure      400,401   {object}  ErrorResponse
// @Router       /api/v1/login [post]
func login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	var user User
	err := db.QueryRow("SELECT id, username, email, password FROM users WHERE username = $1",
		req.Username).Scan(&user.ID, &user.Username, &user.Email, &user.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	if !checkPassword(req.Password, user.Password) {
		c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "Invalid credentials"})
		return
	}

	token := generateToken(user.ID, user.Username)
	c.JSON(http.StatusOK, LoginResponse{Token: token, User: UserInfo{ID: user.ID, Username: user.Username, Email: user.Email}})
}

func generateToken(userID, username string) string {
	claims := Claims{
		UserID:   userID,
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, _ := token.SignedString(secret)
	return tokenString
}

func hashPassword(password string) string {
	// In production, use bcrypt
	return password
}

func checkPassword(password, hashedPassword string) bool {
	// In production, use bcrypt.CompareHashAndPassword
	return password == hashedPassword
}

func authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := c.GetHeader("Authorization")
		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "Authorization header required"})
			c.Abort()
			return
		}

		if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
			tokenString = tokenString[7:]
		}

		token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
			return secret, nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}

		claims := token.Claims.(*Claims)
		c.Set("user_id", claims.UserID)
		c.Set("username", claims.Username)
		c.Next()
	}
}

// Profile godoc
// @Summary      Get user profile / Получить профиль пользователя
// @Description  Get current user profile (JWT required) / Получить профиль по JWT
// @Tags         auth
// @Produce      json
// @Security     BearerAuth
// @Success      200   {object}  map[string]interface{}
// @Failure      401   {object}  map[string]string
// @Router       /api/v1/profile [get]
func StartServer() error {
	r := gin.Default()

	// Swagger documentation
	docs.SwaggerInfo.Title = "Hydration Tracking Auth Service"
	docs.SwaggerInfo.Description = "Authentication and Authorization microservice"
	docs.SwaggerInfo.Version = "1.0"
	docs.SwaggerInfo.Host = "localhost:8081"
	docs.SwaggerInfo.BasePath = "/api/v1"
	docs.SwaggerInfo.Schemes = []string{"http"}

	// Security definitions are set in docs.go

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	api := r.Group("/api/v1")
	{
		api.POST("/register", register)
		api.POST("/login", login)

		// Protected routes
		protected := api.Group("/")
		protected.Use(authMiddleware())
		{
			protected.GET("/profile", func(c *gin.Context) {
				userID := c.GetString("user_id")
				username := c.GetString("username")
				c.JSON(http.StatusOK, gin.H{
					"user_id":  userID,
					"username": username,
				})
			})
		}
	}

	log.Println("Auth service starting on port 8081")
	return r.Run(":8081")
}
