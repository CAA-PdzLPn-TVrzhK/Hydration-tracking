package internal

import (
	"testing"
	"time"
)

func TestValidateEntry(t *testing.T) {
	if !ValidateEntry(200, "water") {
		t.Error("Ожидалось true для валидных данных")
	}
	if ValidateEntry(0, "water") {
		t.Error("Ожидалось false для amount=0")
	}
	if ValidateEntry(-10, "water") {
		t.Error("Ожидалось false для отрицательного amount")
	}
	if ValidateEntry(100, "") {
		t.Error("Ожидалось false для пустого типа")
	}
}

func TestCalculateStats(t *testing.T) {
	now := time.Now()
	entries := []HydrationEntry{
		{Amount: 200, Timestamp: now.Add(-1 * time.Hour)},       // сегодня
		{Amount: 300, Timestamp: now.Add(-2 * 24 * time.Hour)},  // 2 дня назад
		{Amount: 400, Timestamp: now.Add(-10 * 24 * time.Hour)}, // 10 дней назад
	}
	goal := 1000
	stats := CalculateStats(entries, goal)

	if stats.TotalToday != 200 {
		t.Errorf("TotalToday = %d, want 200", stats.TotalToday)
	}
	if stats.TotalWeek != 500 {
		t.Errorf("TotalWeek = %d, want 500", stats.TotalWeek)
	}
	if stats.TotalMonth != 900 {
		t.Errorf("TotalMonth = %d, want 900", stats.TotalMonth)
	}
	if stats.Goal != goal {
		t.Errorf("Goal = %d, want %d", stats.Goal, goal)
	}
	if stats.GoalPercentage != 20 {
		t.Errorf("GoalPercentage = %d, want 20", stats.GoalPercentage)
	}
}
