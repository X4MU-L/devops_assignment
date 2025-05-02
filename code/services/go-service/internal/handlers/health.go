package handlers

import (
	"fmt"
	"net/http"

	"go-service/internal/services"
)

// Handler manages HTTP routes and handlers
type Handler struct {
	service *services.Service
}

// NewHandler creates a new handler instance
func NewHandler(service *services.Service) *Handler {
	return &Handler{service: service}
}

// HealthHandler responds to /health endpoint
func (h *Handler) HealthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, h.service.HealthCheck())
}