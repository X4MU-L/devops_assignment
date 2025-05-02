package tests

import (
	"testing"

	"go-service/config"
	"go-service/internal/services"
)

func TestHealthCheck(t *testing.T) {
	cfg := &config.Config{Port: "8081", Env: "dev"}
	svc := services.NewService(cfg)

	result := svc.HealthCheck()
	expected := "Go Service (dev) is healthy"
	if result != expected {
		t.Errorf("Expected %q, got %q", expected, result)
	}
}

func TestHealthCheckDifferentEnv(t *testing.T) {
	cfg := &config.Config{Port: "8081", Env: "prod"}
	svc := services.NewService(cfg)

	result := svc.HealthCheck()
	expected := "Go Service (prod) is healthy"
	if result != expected {
		t.Errorf("Expected %q, got %q", expected, result)
	}
}