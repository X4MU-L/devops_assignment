package tests

import (
	"os"
	"testing"

	"go-service/config"
)

func TestLoadConfigValid(t *testing.T) {
	// Set environment variables
	os.Setenv("PORT", "8081")
	os.Setenv("ENV", "dev")

	cfg, err := config.Load()
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}
	if cfg.Port != "8081" {
		t.Errorf("Expected Port 8081, got %s", cfg.Port)
	}
	if cfg.Env != "dev" {
		t.Errorf("Expected Env dev, got %s", cfg.Env)
	}
}

func TestLoadConfigMissingPort(t *testing.T) {
	// Clear environment variables
	os.Unsetenv("PORT")
	os.Setenv("ENV", "dev")

	_, err := config.Load()
	if err == nil || err.Error() != "PORT is required" {
		t.Errorf("Expected error 'PORT is required', got %v", err)
	}
}

func TestLoadConfigMissingEnv(t *testing.T) {
	// Set partial environment variables
	os.Setenv("PORT", "8081")
	os.Unsetenv("ENV")

	_, err := config.Load()
	if err == nil || err.Error() != "ENV is required" {
		t.Errorf("Expected error 'ENV is required', got %v", err)
	}
}