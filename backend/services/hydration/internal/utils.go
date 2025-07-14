package internal

import (
	"time"
)

type HydrationEntry struct {
	ID        string
	UserID    string
	Amount    int
	Timestamp time.Time
	Type      string
}

type HydrationStats struct {
	TotalToday     int
	TotalWeek      int
	TotalMonth     int
	Goal           int
	GoalPercentage int
}

// CalculateStats рассчитывает статистику по записям
func CalculateStats(entries []HydrationEntry, goal int) HydrationStats {
	now := time.Now()
	today := now.Format("2006-01-02")
	weekAgo := now.AddDate(0, 0, -7)
	monthAgo := now.AddDate(0, -1, 0)

	totalToday := 0
	totalWeek := 0
	totalMonth := 0
	for _, e := range entries {
		if e.Timestamp.Format("2006-01-02") == today {
			totalToday += e.Amount
		}
		if e.Timestamp.After(weekAgo) {
			totalWeek += e.Amount
		}
		if e.Timestamp.After(monthAgo) {
			totalMonth += e.Amount
		}
	}
	percent := 0
	if goal > 0 {
		percent = totalToday * 100 / goal
	}
	return HydrationStats{
		TotalToday:     totalToday,
		TotalWeek:      totalWeek,
		TotalMonth:     totalMonth,
		Goal:           goal,
		GoalPercentage: percent,
	}
}

// ValidateEntry проверяет валидность данных для записи
func ValidateEntry(amount int, entryType string) bool {
	if amount <= 0 {
		return false
	}
	if entryType == "" {
		return false
	}
	return true
}
