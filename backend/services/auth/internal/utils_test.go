package internal

import (
	"github.com/golang-jwt/jwt/v5"
	"strings"
	"testing"
)

func TestHashPasswordAndCheckPassword(t *testing.T) {
	password := "my-password"
	hashed := HashPassword(password)
	if hashed != password {
		t.Errorf("HashPassword() = %v, want %v", hashed, password)
	}

	if !CheckPassword(password, hashed) {
		t.Error("CheckPassword() = false, want true")
	}

	if CheckPassword("wrong", hashed) {
		t.Error("CheckPassword() = true for wrong password, want false")
	}
}

func TestGenerateToken(t *testing.T) {
	tokenStr, err := GenerateToken("user123", "testuser")
	if err != nil {
		t.Fatalf("GenerateToken() error: %v", err)
	}
	if tokenStr == "" {
		t.Error("GenerateToken() returned empty string")
	}

	// Проверим, что токен можно распарсить
	token, err := jwt.ParseWithClaims(tokenStr, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return secret, nil
	})
	if err != nil {
		t.Fatalf("jwt.ParseWithClaims() error: %v", err)
	}
	if !token.Valid {
		t.Error("Token is not valid")
	}
	claims, ok := token.Claims.(*Claims)
	if !ok {
		t.Fatal("Claims type assertion failed")
	}
	if claims.UserID != "user123" {
		t.Errorf("UserID = %v, want %v", claims.UserID, "user123")
	}
	if claims.Username != "testuser" {
		t.Errorf("Username = %v, want %v", claims.Username, "testuser")
	}
}

func TestGenerateToken_UniqueTokens(t *testing.T) {
	t1, _ := GenerateToken("user1", "u1")
	t2, _ := GenerateToken("user2", "u2")
	if t1 == t2 {
		t.Error("Tokens for different users should not be equal")
	}
	if strings.Count(t1, ".") != 2 {
		t.Error("Token should have 2 dots (JWT format)")
	}
}
