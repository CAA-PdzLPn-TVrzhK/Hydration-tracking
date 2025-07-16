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

	// Создаём записи с точными датами
	todayEntry := HydrationEntry{Amount: 200, Timestamp: now}
	twoDaysAgo := now.AddDate(0, 0, -2)
	twoDaysAgoEntry := HydrationEntry{Amount: 300, Timestamp: twoDaysAgo}
	tenDaysAgo := now.AddDate(0, 0, -10)
	tenDaysAgoEntry := HydrationEntry{Amount: 400, Timestamp: tenDaysAgo}

	entries := []HydrationEntry{
		todayEntry,      // сегодня
		twoDaysAgoEntry, // 2 дня назад
		tenDaysAgoEntry, // 10 дней назад
	}
	goal := 1000
	stats := CalculateStats(entries, goal)

	if stats.TotalToday != 200 {
		t.Errorf("TotalToday = %d, want 200", stats.TotalToday)
	}
	// Записи за последние 7 дней: 200 (сегодня) + 300 (2 дня назад) = 500
	if stats.TotalWeek != 500 {
		t.Errorf("TotalWeek = %d, want 500", stats.TotalWeek)
	}
	// Записи за последний месяц: 200 + 300 + 400 = 900
	if stats.TotalMonth != 900 {
		t.Errorf("TotalMonth = %d, want 900", stats.TotalMonth)
	}
	if stats.Goal != goal {
		t.Errorf("Goal = %d, want %d", stats.Goal, goal)
	}
	// GoalPercentage = (200 / 1000) * 100 = 20
	if stats.GoalPercentage != 20 {
		t.Errorf("GoalPercentage = %d, want 20", stats.GoalPercentage)
	}
}
