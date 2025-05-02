package main

import (
	"log"
	"net/http"

	"go-service/config"
	"go-service/internal/handlers"
	"go-service/internal/services"

	"github.com/gorilla/mux"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}
	log.Printf("Loaded config: %+v", cfg)
	// Initialize service and handler
	service := services.NewService(cfg)
	handler := handlers.NewHandler(service)

	// Set up router
	router := mux.NewRouter()
	router.HandleFunc("/health", handler.HealthHandler).Methods("GET")

	// Start server
	log.Printf("Starting Go Service in %s mode on port %s", cfg.Env, cfg.Port)
	if err := http.ListenAndServe(":"+cfg.Port, router); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}