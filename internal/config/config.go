package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	DBHost     string
	DBPort     string
	DBName     string
	DBUser     string
	DBPassword string
	Port       string
	JWTSecret  string
}

func Load() (*Config, error) {
	// Load .env file jika ada (tidak error jika tidak ada,
	// karena di production env vars di-set langsung di server)
	godotenv.Load()

	return &Config{
		DBHost:     getEnv("DB_HOST", "localhost"),
		DBPort:     getEnv("DB_PORT", "5433"),
		DBName:     getEnv("DB_NAME", "crm_telemarketing"),
		DBUser:     getEnv("DB_USER", "crm_admin"),
		DBPassword: getEnv("DB_PASSWORD", ""),
		Port:       getEnv("PORT", "8080"),
		JWTSecret:  getEnv("JWT_SECRET", ""),
	}, nil
}

// DatabaseURL mengembalikan connection string untuk pgx
func (c *Config) DatabaseURL() string {
	return fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		c.DBUser, c.DBPassword, c.DBHost, c.DBPort, c.DBName)
}

// getEnv membaca env variable, jika tidak ada pakai fallback
func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
