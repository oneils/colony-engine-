package server

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

type Server struct{}

func (s *Server) routes() chi.Router {
	router := chi.NewRouter()

	router.Group(func(r chi.Router) {
		r.Use(middleware.Logger)

		r.Get("/health", s.healthCheckHandler)
		r.Get("/readiness", s.readinessCheckHandler)

		router.Route("/npcs/state", func(r chi.Router) {
			r.Get("/", s.npscStateHandler)
		})

		r.Get("/", s.indexHandler)
	})

	return router
}

func (s *Server) Run(ctx context.Context, addr string) error {

	httpServer := &http.Server{
		Addr:              addr,
		Handler:           s.routes(),
		ReadHeaderTimeout: 10 * time.Second,
		WriteTimeout:      60 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	serverErrors := make(chan error, 1)

	go func() {
		slog.Info("HTTP Server listening", "addr", addr)
		serverErrors <- httpServer.ListenAndServe()
	}()

	select {
	case err := <-serverErrors:
		if err != nil && err != http.ErrServerClosed {
			return err
		}

	case <-ctx.Done():
		slog.Info("shutdown signal received, starting graceful shutdown")

		shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		if err := httpServer.Shutdown(shutdownCtx); err != nil {
			slog.Error("graceful shutdown failed", "error", err)
			if closeErr := httpServer.Close(); closeErr != nil {
				slog.Error("failed to force close http server", "error", closeErr)
			}
			return err
		}

		slog.Info("HTTP server gracefully stopped")
	}

	return nil
}
