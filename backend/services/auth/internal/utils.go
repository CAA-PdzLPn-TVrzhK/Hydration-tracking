package internal

import (
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type Claims struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	jwt.RegisteredClaims
}

var secret = []byte("test-secret-key")

func HashPassword(password string) string {
	// В реальном проекте используйте bcrypt
	return password
}

func CheckPassword(password, hashedPassword string) bool {
	// В реальном проекте используйте bcrypt.CompareHashAndPassword
	return password == hashedPassword
}

func GenerateToken(userID, username string) (string, error) {
	claims := Claims{
		UserID:   userID,
		Username: username,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(secret)
}
