package config

import (
	"fmt"
	"os"
)

// Config holds service configuration
type Config struct {
	Port string
	Env  string
}

// Load retrieves configuration from environment variables
func Load() (*Config, error) {
	cfg := &Config{
		Port: getEnv("PORT", "8081"),
		Env:  getEnv("ENV", "dev"),
	}

	if cfg.Port == "" {
		return nil, fmt.Errorf("PORT is required")
	}
	if cfg.Env == "" {
		return nil, fmt.Errorf("ENV is required")
	}

	return cfg, nil
}

// getEnv retrieves environment variable with fallback
func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists && value != "" {
		return value
	}
	return fallback
}