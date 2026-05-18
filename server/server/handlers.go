package server

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"github.com/oneils/colony-engine/colony-engine-server/world"
)

func (s *Server) indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	resp := map[string]string{"status": "OK"}
	json.NewEncoder(w).Encode(resp)

}

func (s *Server) npscStateHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	state := world.FetchState()
	json.NewEncoder(w).Encode(state)
}

func (s *Server) healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	health := map[string]interface{}{
		"status":    "ok",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
		"service":   "colony-engine",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(health); err != nil {
		slog.Error("failed to encode health check response", "error", err)
	}
}

func (s *Server) readinessCheckHandler(w http.ResponseWriter, r *http.Request) {

	readiness := map[string]interface{}{
		"status":    "ready",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
		"service":   "budget-keeper",
		"checks": map[string]string{
			"server": "ok",
		},
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(readiness); err != nil {
		slog.Error("failed to encode readiness check response", "error", err)
	}
}

func (s *Server) fetchGameCfg(w http.ResponseWriter, r *http.Request) {

	gameCfg := world.GameCfg{
		Grid: world.GridCfg{
			Width: 17,
			Hight: 8,
		},
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(gameCfg); err != nil {
		slog.Error("failed to get Game configuration", "error", err)
		w.WriteHeader(http.StatusInternalServerError)
	}
}
