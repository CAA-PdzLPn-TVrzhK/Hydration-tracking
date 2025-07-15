package main

import (
    "bufio"
    "log"
    "os"
    "os/signal"
    "strings"
    "syscall"

    "hydration-tracking/services/auth"
    "hydration-tracking/services/hydration"
)

func loadEnvFile(filename string) error {
    file, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        line := strings.TrimSpace(scanner.Text())
        if line == "" || strings.HasPrefix(line, "#") {
            continue
        }
        
        if strings.Contains(line, "=") {
            parts := strings.SplitN(line, "=", 2)
            if len(parts) == 2 {
                key := strings.TrimSpace(parts[0])
                value := strings.TrimSpace(parts[1])
                // Remove quotes if present
                if len(value) > 1 && (value[0] == '"' && value[len(value)-1] == '"') {
                    value = value[1 : len(value)-1]
                }
                os.Setenv(key, value)
            }
        }
    }
    return scanner.Err()
}

func main() {
    // Load environment variables from config.env
    if err := loadEnvFile("config.env"); err != nil {
        log.Printf("Warning: Could not load config.env: %v", err)
    }

	go func() {
		if err := auth.StartServer(); err != nil {
			log.Fatalf("Auth service error: %v", err)
		}
	}()
	go func() {
		if err := hydration.StartServer(); err != nil {
			log.Fatalf("Hydration service error: %v", err)
		}
	}()
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down...")
} 