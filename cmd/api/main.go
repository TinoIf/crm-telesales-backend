package main

import (
	"context"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/tfrfrfr/crm-telesales-backend/internal/config"
	"github.com/tfrfrfr/crm-telesales-backend/internal/handler"
)

func main() {
	// 1. Load config dari .env
	cfg, err := config.Load()
	if err != nil {
		log.Fatal("❌ Failed to load config:", err)
	}

	// 2. Connect ke database PostgreSQL
	pool, err := pgxpool.New(context.Background(), cfg.DatabaseURL())
	if err != nil {
		log.Fatal("❌ Failed to connect database:", err)
	}
	defer pool.Close()

	// Test koneksi — pastikan database bisa dijangkau
	if err := pool.Ping(context.Background()); err != nil {
		log.Fatal("❌ Failed to ping database:", err)
	}
	log.Println("✅ Database connected successfully")

	// 3. Setup router Gin
	router := gin.Default()

	// Routes
	v1 := router.Group("/api/v1")
	{
		v1.GET("/health", handler.HealthCheck)
	}

	// 4. Start server
	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("🚀 Server starting on http://localhost%s", addr)
	log.Printf("📋 Health check: http://localhost%s/api/v1/health", addr)

	if err := router.Run(addr); err != nil {
		log.Fatal("❌ Failed to start server:", err)
	}
}
