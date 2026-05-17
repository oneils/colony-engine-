package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/oneils/colony-engine/colony-engine-server/app"
	"github.com/umputun/go-flags"
)

var revision = "unknown"

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	slog.Info("starting the colony server", "version", revision)

	var cfg app.Config
	if _, err := flags.Parse(&cfg); err != nil {
		slog.Error("failed to parse flags", "error", err)
		os.Exit(1)
	}

	slog.Info("configuration loaded", "addr", cfg.Addr)

	// Create application
	application, err := app.New(cfg)
	if err != nil {
		slog.Error("failed to create application", "error", err)
		os.Exit(1)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM, syscall.SIGINT)
	defer stop()

	slog.Info("starting the Colony server", "addr", cfg.Addr)
	if err := application.Run(ctx); err != nil {
		slog.Error("application failed", "error", err)
		os.Exit(1)
	}

	// Cleanup
	if err := application.Close(context.Background()); err != nil {
		slog.Error("failed to close application", "error", err)
	}

	slog.Info("Colony APP stopped")

}
