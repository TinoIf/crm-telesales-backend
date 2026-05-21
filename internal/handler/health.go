package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// HealthCheck adalah endpoint untuk memastikan server berjalan.
// Ini endpoint standar di setiap production API — monitoring tools
// (seperti Docker, load balancer) akan ping endpoint ini untuk cek
// apakah server masih hidup.
func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":  "ok",
		"message": "CRM Telemarketing API is running",
		"version": "v1",
	})
}
