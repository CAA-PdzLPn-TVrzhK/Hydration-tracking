package hydration

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

	"hydration-tracking/services/hydration/docs"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	_ "github.com/lib/pq"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

type HydrationEntry struct {
	ID        string    `json:"id" example:"550e8400-e29b-41d4-a716-446655440000"`
	UserID    string    `json:"user_id" example:"550e8400-e29b-41d4-a716-446655440000"`
	Amount    int       `json:"amount" example:"250"`
	Timestamp time.Time `json:"timestamp" example:"2024-01-15T10:30:00Z"`
	Type      string    `json:"type" example:"water"`
}

type CreateEntryRequest struct {
	Amount int    `json:"amount" binding:"required,min=1" example:"250"`
	Type   string `json:"type" binding:"required" example:"water"`
}

type UpdateGoalRequest struct {
	Goal int `json:"goal" binding:"required,min=1" example:"2000"`
}

type HydrationStats struct {
	TotalToday     int `json:"total_today" example:"1500"`
	TotalWeek      int `json:"total_week" example:"10500"`
	TotalMonth     int `json:"total_month" example:"45000"`
	Goal           int `json:"goal" example:"2000"`
	GoalPercentage int `json:"goal_percentage" example:"75"`
}

type ErrorResponse struct {
	Error string `json:"error" example:"Invalid input data"`
}

type UpdateGoalResponse struct {
	Message string `json:"message" example:"Goal updated successfully"`
	Goal    int    `json:"goal" example:"2000"`
}

type Claims struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	jwt.RegisteredClaims
}

var (
	db     *sql.DB
	secret []byte
)

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func initSecret() {
	envSecret := os.Getenv("JWT_SECRET")
	if envSecret == "" {
		log.Fatal("JWT_SECRET env variable not set")
	}
	secret = []byte(envSecret)
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
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}

	createTable := `
	CREATE TABLE IF NOT EXISTS hydration_entries (
		id UUID PRIMARY KEY,
		user_id UUID NOT NULL,
		amount INTEGER NOT NULL,
		timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		type VARCHAR(50) NOT NULL,
		FOREIGN KEY (user_id) REFERENCES users(id)
	);`

	_, err = db.Exec(createTable)
	if err != nil {
		log.Fatal(err)
	}

	// Create user_goals table
	createGoalsTable := `
	CREATE TABLE IF NOT EXISTS user_goals (
		user_id UUID PRIMARY KEY,
		daily_goal INTEGER DEFAULT 2000,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (user_id) REFERENCES users(id)
	);`

	_, err = db.Exec(createGoalsTable)
	if err != nil {
		log.Fatal(err)
	}
}

// CreateEntry godoc
// @Summary      Add hydration entry / Добавить запись о приёме воды
// @Description  Add a new hydration entry for the user / Добавить новую запись о приёме воды
// @Tags         hydration
// @Accept       json
// @Produce      json
// @Param        data  body  CreateEntryRequest  true  "Entry data / Данные записи"
// @Success      201   {object}  HydrationEntry  "Entry created successfully"
// @Failure      400   {object}  ErrorResponse  "Bad Request - Invalid input"
// @Failure      401   {object}  ErrorResponse  "Unauthorized - Invalid token"
// @Failure      500   {object}  ErrorResponse  "Internal Server Error"
// @Security     BearerAuth
// @Router       /api/v1/entries [post]
func createEntry(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "User not authenticated"})
		return
	}

	var req CreateEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	entryID := uuid.New().String()
	entry := HydrationEntry{
		ID:        entryID,
		UserID:    userID,
		Amount:    req.Amount,
		Type:      req.Type,
		Timestamp: time.Now(),
	}

	_, err := db.Exec("INSERT INTO hydration_entries (id, user_id, amount, type) VALUES ($1, $2, $3, $4)",
		entry.ID, entry.UserID, entry.Amount, entry.Type)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{Error: "Failed to create entry"})
		return
	}

	c.JSON(http.StatusCreated, entry)
}

// GetEntries godoc
// @Summary      Get all hydration entries / Получить все записи
// @Description  Get all hydration entries for the user / Получить все записи пользователя
// @Tags         hydration
// @Produce      json
// @Success      200   {array}  HydrationEntry  "List of hydration entries"
// @Failure      401   {object}  ErrorResponse  "Unauthorized - Invalid token"
// @Failure      500   {object}  ErrorResponse  "Internal Server Error"
// @Security     BearerAuth
// @Router       /api/v1/entries [get]
func getEntries(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "User not authenticated"})
		return
	}

	rows, err := db.Query("SELECT id, user_id, amount, timestamp, type FROM hydration_entries WHERE user_id = $1 ORDER BY timestamp DESC", userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{Error: "Failed to fetch entries"})
		return
	}
	defer rows.Close()

	var entries []HydrationEntry
	for rows.Next() {
		var entry HydrationEntry
		err := rows.Scan(&entry.ID, &entry.UserID, &entry.Amount, &entry.Timestamp, &entry.Type)
		if err != nil {
			continue
		}
		entries = append(entries, entry)
	}

	c.JSON(http.StatusOK, entries)
}

// GetStats godoc
// @Summary      Get hydration stats / Получить статистику
// @Description  Get hydration statistics for the user / Получить статистику пользователя
// @Tags         hydration
// @Produce      json
// @Success      200   {object}  HydrationStats  "Hydration statistics"
// @Failure      401   {object}  ErrorResponse  "Unauthorized - Invalid token"
// @Failure      500   {object}  ErrorResponse  "Internal Server Error"
// @Security     BearerAuth
// @Router       /api/v1/stats [get]
func getStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "User not authenticated"})
		return
	}

	// Get daily goal
	var goal int
	err := db.QueryRow("SELECT daily_goal FROM user_goals WHERE user_id = $1", userID).Scan(&goal)
	if err != nil {
		// Set default goal if not found
		goal = 2000
		_, err = db.Exec("INSERT INTO user_goals (user_id, daily_goal) VALUES ($1, $2)", userID, goal)
		if err != nil {
			log.Printf("Failed to create user goal: %v", err)
		}
	}

	// Get today's total
	var totalToday int
	today := time.Now().Format("2006-01-02")
	err = db.QueryRow("SELECT COALESCE(SUM(amount), 0) FROM hydration_entries WHERE user_id = $1 AND DATE(timestamp) = $2",
		userID, today).Scan(&totalToday)
	if err != nil {
		totalToday = 0
	}

	// Get week's total
	var totalWeek int
	weekAgo := time.Now().AddDate(0, 0, -7).Format("2006-01-02")
	err = db.QueryRow("SELECT COALESCE(SUM(amount), 0) FROM hydration_entries WHERE user_id = $1 AND DATE(timestamp) >= $2",
		userID, weekAgo).Scan(&totalWeek)
	if err != nil {
		totalWeek = 0
	}

	// Get month's total
	var totalMonth int
	monthAgo := time.Now().AddDate(0, -1, 0).Format("2006-01-02")
	err = db.QueryRow("SELECT COALESCE(SUM(amount), 0) FROM hydration_entries WHERE user_id = $1 AND DATE(timestamp) >= $2",
		userID, monthAgo).Scan(&totalMonth)
	if err != nil {
		totalMonth = 0
	}

	percent := 0
	if goal > 0 {
		percent = totalToday * 100 / goal
	}

	stats := HydrationStats{
		TotalToday:     totalToday,
		TotalWeek:      totalWeek,
		TotalMonth:     totalMonth,
		Goal:           goal,
		GoalPercentage: percent,
	}

	c.JSON(http.StatusOK, stats)
}

// UpdateGoal godoc
// @Summary      Update daily goal / Обновить дневную цель
// @Description  Update daily hydration goal for the user / Обновить дневную цель пользователя
// @Tags         hydration
// @Accept       json
// @Produce      json
// @Param        data  body  UpdateGoalRequest  true  "Goal data / Новая цель"
// @Success      200   {object}  UpdateGoalResponse  "Goal updated successfully"
// @Failure      400   {object}  ErrorResponse  "Bad Request - Invalid input"
// @Failure      401   {object}  ErrorResponse  "Unauthorized - Invalid token"
// @Failure      500   {object}  ErrorResponse  "Internal Server Error"
// @Security     BearerAuth
// @Router       /api/v1/goal [put]
func updateGoal(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "User not authenticated"})
		return
	}

	var req UpdateGoalRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	_, err := db.Exec("INSERT INTO user_goals (user_id, daily_goal) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET daily_goal = $2, updated_at = CURRENT_TIMESTAMP",
		userID, req.Goal)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{Error: "Failed to update goal"})
		return
	}

	c.JSON(http.StatusOK, UpdateGoalResponse{Message: "Goal updated successfully", Goal: req.Goal})
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
			c.JSON(http.StatusUnauthorized, ErrorResponse{Error: "Invalid token"})
			c.Abort()
			return
		}

		claims := token.Claims.(*Claims)
		c.Set("user_id", claims.UserID)
		c.Set("username", claims.Username)
		c.Next()
	}
}

func StartServer() error {
	initSecret()
	r := gin.Default()

	// Swagger documentation
	docs.SwaggerInfo.Title = "Hydration Tracking Service"
	docs.SwaggerInfo.Description = "Hydration tracking microservice"
	docs.SwaggerInfo.Version = "1.0"
	docs.SwaggerInfo.Host = "localhost:8082"
	docs.SwaggerInfo.BasePath = "/api/v1"
	docs.SwaggerInfo.Schemes = []string{"http"}

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.GET("/health", func(c *gin.Context) {
		c.String(200, "healthy")
	})

	api := r.Group("/api/v1")
	api.Use(authMiddleware())
	{
		api.POST("/entries", createEntry)
		api.GET("/entries", getEntries)
		api.GET("/stats", getStats)
		api.PUT("/goal", updateGoal)
	}

	log.Println("Hydration service starting on port 8082")
	return r.Run(":8082")
}
