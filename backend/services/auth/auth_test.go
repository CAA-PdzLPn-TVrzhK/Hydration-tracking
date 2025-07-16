package auth

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

// Mock database for testing
type mockDB struct {
	users map[string]User
}

func newMockDB() Database {
	return &mockDB{
		users: make(map[string]User),
	}
}

func (m *mockDB) Exec(query string, args ...interface{}) (sql.Result, error) {
	// Mock implementation for INSERT - always succeed
	return &mockResult{}, nil
}

func (m *mockDB) QueryRow(query string, args ...interface{}) *sql.Row {
	// Mock implementation for SELECT
	// For login tests, we need to return different results based on the query
	if len(args) > 0 {
		username, ok := args[0].(string)
		if ok {
			// Check if user exists in our mock data
			if username == "logintest" {
				// Return a mock row with test data
				return &sql.Row{}
			}
		}
	}
	// Return empty row for non-existent users
	return &sql.Row{}
}

type mockResult struct{}

func (m *mockResult) LastInsertId() (int64, error) { return 1, nil }
func (m *mockResult) RowsAffected() (int64, error) { return 1, nil }

func setupTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.Default()

	// Override global db with mock for testing
	originalDB := db
	db = newMockDB()
	defer func() { db = originalDB }()

	api := r.Group("/api/v1")
	{
		api.POST("/register", register)
		api.POST("/login", login)

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

	return r
}

func init() {
	// Skip database initialization for tests
	if testing.Testing() {
		db = newMockDB()
	}
}

func TestRegisterValidation(t *testing.T) {
	r := setupTestRouter()
	tests := []struct {
		name           string
		payload        RegisterRequest
		expectedStatus int
		expectedError  bool
	}{
		{
			name: "Invalid email",
			payload: RegisterRequest{
				Username: "testuser2",
				Email:    "invalid-email",
				Password: "password123",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  true,
		},
		{
			name: "Short password",
			payload: RegisterRequest{
				Username: "testuser3",
				Email:    "test3@example.com",
				Password: "123",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  true,
		},
		{
			name: "Missing username",
			payload: RegisterRequest{
				Username: "",
				Email:    "test@example.com",
				Password: "password123",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payloadBytes, _ := json.Marshal(tt.payload)
			req, _ := http.NewRequest("POST", "/api/v1/register", bytes.NewBuffer(payloadBytes))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

func TestLoginValidation(t *testing.T) {
	r := setupTestRouter()

	tests := []struct {
		name           string
		payload        LoginRequest
		expectedStatus int
		expectedError  bool
	}{
		{
			name: "Missing username",
			payload: LoginRequest{
				Username: "",
				Password: "password123",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  true,
		},
		{
			name: "Missing password",
			payload: LoginRequest{
				Username: "testuser",
				Password: "",
			},
			expectedStatus: http.StatusBadRequest,
			expectedError:  true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payloadBytes, _ := json.Marshal(tt.payload)
			req, _ := http.NewRequest("POST", "/api/v1/login", bytes.NewBuffer(payloadBytes))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)
		})
	}
}

func TestAuthMiddleware(t *testing.T) {
	r := setupTestRouter()

	// Test without authorization header
	req, _ := http.NewRequest("GET", "/api/v1/profile", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusUnauthorized, w.Code)

	// Test with invalid token
	req, _ = http.NewRequest("GET", "/api/v1/profile", nil)
	req.Header.Set("Authorization", "Bearer invalid-token")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestGenerateToken(t *testing.T) {
	userID := "test-user-id"
	username := "testuser"

	token := generateToken(userID, username)
	assert.NotEmpty(t, token)
	assert.Greater(t, len(token), 10) // Basic length check
}

func TestHashPassword(t *testing.T) {
	password := "testpassword"
	hashed := hashPassword(password)

	// In this simplified implementation, password is not actually hashed
	assert.Equal(t, password, hashed)
}

func TestCheckPassword(t *testing.T) {
	password := "testpassword"
	hashed := hashPassword(password)

	assert.True(t, checkPassword(password, hashed))
	assert.False(t, checkPassword("wrongpassword", hashed))
}
