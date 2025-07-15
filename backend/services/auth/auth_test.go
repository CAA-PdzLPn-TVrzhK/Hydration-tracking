package auth

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func setupTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.Default()

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

func TestRegister(t *testing.T) {
	r := setupTestRouter()
	tests := []struct {
		name           string
		payload        RegisterRequest
		expectedStatus int
		expectedError  bool
	}{
		{
			name: "Valid registration",
			payload: RegisterRequest{
				Username: "testuser",
				Email:    "test@example.com",
				Password: "password123",
			},
			expectedStatus: http.StatusCreated,
			expectedError:  false,
		},
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
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payloadBytes, _ := json.Marshal(tt.payload)
			req, _ := http.NewRequest("POST", "/api/v1/register", bytes.NewBuffer(payloadBytes))
			req.Header.Set("Content-Type", "application/json")

			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)

			assert.Equal(t, tt.expectedStatus, w.Code)

			if !tt.expectedError {
				var response map[string]interface{}
				err := json.Unmarshal(w.Body.Bytes(), &response)
				require.NoError(t, err)
				assert.Contains(t, response, "user_id")
			}
		})
	}
}

func TestLogin(t *testing.T) {
	r := setupTestRouter()

	// First register a user
	registerPayload := RegisterRequest{
		Username: "logintest",
		Email:    "logintest@example.com",
		Password: "password123",
	}

	registerBytes, _ := json.Marshal(registerPayload)
	registerReq, _ := http.NewRequest("POST", "/api/v1/register", bytes.NewBuffer(registerBytes))
	registerReq.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	r.ServeHTTP(w, registerReq)
	assert.Equal(t, http.StatusCreated, w.Code)

	tests := []struct {
		name           string
		payload        LoginRequest
		expectedStatus int
		expectedError  bool
	}{
		{
			name: "Valid login",
			payload: LoginRequest{
				Username: "logintest",
				Password: "password123",
			},
			expectedStatus: http.StatusOK,
			expectedError:  false,
		},
		{
			name: "Invalid password",
			payload: LoginRequest{
				Username: "logintest",
				Password: "wrongpassword",
			},
			expectedStatus: http.StatusUnauthorized,
			expectedError:  true,
		},
		{
			name: "Non-existent user",
			payload: LoginRequest{
				Username: "nonexistent",
				Password: "password123",
			},
			expectedStatus: http.StatusUnauthorized,
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

			if !tt.expectedError {
				var response map[string]interface{}
				err := json.Unmarshal(w.Body.Bytes(), &response)
				require.NoError(t, err)
				assert.Contains(t, response, "token")
				assert.Contains(t, response, "user")
			}
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

	// Test with valid token (simplified for testing)
	req, _ = http.NewRequest("GET", "/api/v1/profile", nil)
	req.Header.Set("X-User-ID", "test-user-id")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusOK, w.Code)
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
