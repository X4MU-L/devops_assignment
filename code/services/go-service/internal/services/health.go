package services

import (
	"fmt"

	"go-service/config"
)

// Service handles business logic
type Service struct {
	config *config.Config
}

// NewService creates a new service instance
func NewService(config *config.Config) *Service {
	return &Service{config: config}
}

// HealthCheck handles health check logic
func (s *Service) HealthCheck() string {
	return fmt.Sprintf("Go Service (%s) is healthy", s.config.Env)
}