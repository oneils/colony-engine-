package app

import (
	"context"

	"github.com/oneils/colony-engine/colony-engine-server/server"
)

// Config holds all application configuration.
type Config struct {
	Addr string `long:"addr" env:"ADDR" default:":8080" description:"HTTP service address"`
}

// App represents the application with all its dependencies.
type App struct {
	Config Config
	Server *server.Server
}

func New(cfg Config) (*App, error) {

	srv := &server.Server{}

	return &App{
		Config: cfg,
		Server: srv,
	}, nil
}

// Run starts the application.
func (a *App) Run(ctx context.Context) error {
	return a.Server.Run(ctx, a.Config.Addr)
}

// Close closes all application resources.
func (a *App) Close(ctx context.Context) error {
	return nil
}
