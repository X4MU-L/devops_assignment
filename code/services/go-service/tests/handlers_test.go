package tests

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"go-service/config"
	"go-service/internal/handlers"
	"go-service/internal/services"
)

func TestHealthHandler(t *testing.T) {
	cfg := &config.Config{Port: "8081", Env: "dev"}
	svc := services.NewService(cfg)
	handler := handlers.NewHandler(svc)

	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler.HealthHandler(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Expected status %v, got %v", http.StatusOK, status)
	}

	expected := "Go Service (dev) is healthy"
	if rr.Body.String() != expected {
		t.Errorf("Expected body %q, got %q", expected, rr.Body.String())
	}
}

func TestHealthHandlerDifferentEnv(t *testing.T) {
	cfg := &config.Config{Port: "8081", Env: "prod"}
	svc := services.NewService(cfg)
	handler := handlers.NewHandler(svc)

	req, err := http.NewRequest("GET", "/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler.HealthHandler(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Expected status %v, got %v", http.StatusOK, status)
	}

	expected := "Go Service (prod) is healthy"
	if rr.Body.String() != expected {
		t.Errorf("Expected body %q, got %q", expected, rr.Body.String())
	}
}