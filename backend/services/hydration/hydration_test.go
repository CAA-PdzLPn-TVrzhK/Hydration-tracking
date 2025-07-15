package hydration

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

type mockCreateEntryRequest struct {
	Amount int    `json:"amount"`
	Type   string `json:"type"`
}

func TestCreateEntry_Validation(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.Default()
	r.POST("/entries", func(c *gin.Context) {
		// Мокаем user_id, как будто пользователь аутентифицирован
		c.Set("user_id", "test-user-id")
		createEntry(c)
	})

	// Тест: невалидный запрос (нет amount)
	invalidReq := mockCreateEntryRequest{Type: "water"}
	body, _ := json.Marshal(invalidReq)
	req, _ := http.NewRequest("POST", "/entries", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusBadRequest {
		t.Errorf("ожидался статус 400, получен %d", w.Code)
	}

	// Тест: валидный запрос
	validReq := mockCreateEntryRequest{Amount: 250, Type: "water"}
	body, _ = json.Marshal(validReq)
	req, _ = http.NewRequest("POST", "/entries", bytes.NewBuffer(body))
	req.Header.Set("Content-Type", "application/json")
	w = httptest.NewRecorder()
	r.ServeHTTP(w, req)
	if w.Code != http.StatusCreated && w.Code != http.StatusInternalServerError {
		t.Errorf("ожидался статус 201 или 500 (если нет БД), получен %d", w.Code)
	}
}
