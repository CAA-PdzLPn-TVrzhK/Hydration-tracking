package main

import (
	"database/sql"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	_ "github.com/lib/pq"
	"github.com/swaggo/files"
	"github.com/swaggo/gin-swagger"
	"github.com/swaggo/swag/example/basic/docs"
)

// @title Hydration Tracking Service
// @version 1.0
// @description Hydration tracking microservice for logging water intake
// @host localhost:8082
// @BasePath /api/v1

type HydrationEntry struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Amount    int       `json:"amount"` // in ml
	Timestamp time.Time `json:"timestamp"`
	Type      string    `json:"type"` // water, tea, coffee, etc.
}

type CreateEntryRequest struct {
	Amount int    `json:"amount" binding:"required,min=1"`
	Type   string `json:"type" binding:"required"`
}

type HydrationStats struct {
	TotalToday     int `json:"total_today"`
	TotalWeek      int `json:"total_week"`
	TotalMonth     int `json:"total_month"`
	Goal           int `json:"goal"`
	GoalPercentage int `json:"goal_percentage"`
}

var db *sql.DB

func init() {
	connStr := "postgres://postgres:password@postgres:5432/hydration_tracking?sslmode=disable"
	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}

	// Create hydration_entries table
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

// @Summary Log water intake
// @Description Log a new hydration entry for the authenticated user
// @Tags hydration
// @Accept json
// @Produce json
// @Param entry body CreateEntryRequest true "Hydration entry data"
// @Success 201 {object} HydrationEntry
// @Failure 400 {object} map[string]interface{}
// @Router /entries [post]
func createEntry(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var req CreateEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create entry"})
		return
	}

	c.JSON(http.StatusCreated, entry)
}

// @Summary Get user's hydration entries
// @Description Retrieve all hydration entries for the authenticated user
// @Tags hydration
// @Produce json
// @Success 200 {array} HydrationEntry
// @Failure 401 {object} map[string]interface{}
// @Router /entries [get]
func getEntries(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	rows, err := db.Query("SELECT id, user_id, amount, timestamp, type FROM hydration_entries WHERE user_id = $1 ORDER BY timestamp DESC", userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch entries"})
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

// @Summary Get hydration statistics
// @Description Get hydration statistics for the authenticated user
// @Tags hydration
// @Produce json
// @Success 200 {object} HydrationStats
// @Failure 401 {object} map[string]interface{}
// @Router /stats [get]
func getStats(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
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

	goalPercentage := 0
	if goal > 0 {
		goalPercentage = (totalToday * 100) / goal
	}

	stats := HydrationStats{
		TotalToday:     totalToday,
		TotalWeek:      totalWeek,
		TotalMonth:     totalMonth,
		Goal:           goal,
		GoalPercentage: goalPercentage,
	}

	c.JSON(http.StatusOK, stats)
}

// @Summary Update daily goal
// @Description Update the daily hydration goal for the authenticated user
// @Tags hydration
// @Accept json
// @Produce json
// @Param goal body map[string]int true "Daily goal in ml"
// @Success 200 {object} map[string]interface{}
// @Failure 400 {object} map[string]interface{}
// @Router /goal [put]
func updateGoal(c *gin.Context) {
	userID := c.GetString("user_id")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	var req struct {
		Goal int `json:"goal" binding:"required,min=1"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := db.Exec("INSERT INTO user_goals (user_id, daily_goal) VALUES ($1, $2) ON CONFLICT (user_id) DO UPDATE SET daily_goal = $2, updated_at = CURRENT_TIMESTAMP",
		userID, req.Goal)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update goal"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Goal updated successfully", "goal": req.Goal})
}

func authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := c.GetHeader("Authorization")
		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			c.Abort()
			return
		}

		if len(tokenString) > 7 && tokenString[:7] == "Bearer " {
			tokenString = tokenString[7:]
		}

		// In a real implementation, you would validate the JWT token here
		// For now, we'll extract user_id from a simple header
		userID := c.GetHeader("X-User-ID")
		if userID == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID required"})
			c.Abort()
			return
		}

		c.Set("user_id", userID)
		c.Next()
	}
}

func main() {
	r := gin.Default()

	// Swagger documentation
	docs.SwaggerInfo.Title = "Hydration Tracking Service"
	docs.SwaggerInfo.Description = "Hydration tracking microservice"
	docs.SwaggerInfo.Version = "1.0"
	docs.SwaggerInfo.Host = "localhost:8082"
	docs.SwaggerInfo.BasePath = "/api/v1"
	docs.SwaggerInfo.Schemes = []string{"http"}

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	api := r.Group("/api/v1")
	api.Use(authMiddleware())
	{
		api.POST("/entries", createEntry)
		api.GET("/entries", getEntries)
		api.GET("/stats", getStats)
		api.PUT("/goal", updateGoal)
	}

	log.Println("Hydration service starting on port 8082")
	r.Run(":8082")
}
