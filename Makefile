# Makefile for OCR Simple Application

# Variables
APP_NAME=ocr-app
MAIN_FILE=main.go
BUILD_DIR=./build
BINARY_NAME=$(APP_NAME)
GO_VERSION=1.23.6
PORT=8080

# Colors for output
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Help target
.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)OCR Simple Application - Available Commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# Check if Go is installed
.PHONY: check-go
check-go: ## Check if Go is installed
	@echo "$(BLUE)Checking Go installation...$(NC)"
	@which go > /dev/null || (echo "$(RED)Error: Go is not installed. Please install Go $(GO_VERSION) or later.$(NC)" && exit 1)
	@echo "$(GREEN)Go is installed: $$(go version)$(NC)"

# Check if Tesseract is installed
.PHONY: check-tesseract
check-tesseract: ## Check if Tesseract OCR is installed
	@echo "$(BLUE)Checking Tesseract installation...$(NC)"
	@which tesseract > /dev/null || (echo "$(RED)Error: Tesseract is not installed. Please install Tesseract OCR.$(NC)" && exit 1)
	@echo "$(GREEN)Tesseract is installed: $$(tesseract --version | head -n1)$(NC)"

# Check all dependencies
.PHONY: check-deps
check-deps: check-go check-tesseract ## Check all required dependencies
	@echo "$(GREEN)All dependencies are satisfied!$(NC)"

# Install Go dependencies
.PHONY: deps
deps: check-go ## Download and install Go dependencies
	@echo "$(BLUE)Installing Go dependencies...$(NC)"
	go mod download
	go mod tidy
	@echo "$(GREEN)Dependencies installed successfully!$(NC)"

# Build the application
.PHONY: build
build: check-deps ## Build the application
	@echo "$(BLUE)Building $(APP_NAME)...$(NC)"
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_FILE)
	@echo "$(GREEN)Build completed: $(BUILD_DIR)/$(BINARY_NAME)$(NC)"

# Build for production (with optimizations)
.PHONY: build-prod
build-prod: check-deps ## Build the application for production
	@echo "$(BLUE)Building $(APP_NAME) for production...$(NC)"
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=1 go build -ldflags "-s -w" -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_FILE)
	@echo "$(GREEN)Production build completed: $(BUILD_DIR)/$(BINARY_NAME)$(NC)"

# Run the application directly
.PHONY: run
run: check-deps ## Run the application directly (without building)
	@echo "$(BLUE)Starting $(APP_NAME) on port $(PORT)...$(NC)"
	@echo "$(YELLOW)Access the application at: http://localhost:$(PORT)$(NC)"
	go run $(MAIN_FILE)

# Run the built binary
.PHONY: start
start: build ## Build and run the application
	@echo "$(BLUE)Starting $(APP_NAME) from binary...$(NC)"
	@echo "$(YELLOW)Access the application at: http://localhost:$(PORT)$(NC)"
	$(BUILD_DIR)/$(BINARY_NAME)

# Development mode with auto-reload (requires air)
.PHONY: dev
dev: check-deps ## Run in development mode with auto-reload
	@echo "$(BLUE)Starting development server...$(NC)"
	@if which air > /dev/null; then \
		echo "$(GREEN)Using air for auto-reload$(NC)"; \
		air; \
	else \
		echo "$(YELLOW)Air not found. Install with: go install github.com/cosmtrek/air@latest$(NC)"; \
		echo "$(BLUE)Running without auto-reload...$(NC)"; \
		make run; \
	fi

# Install development tools
.PHONY: install-dev-tools
install-dev-tools: ## Install development tools (air for auto-reload)
	@echo "$(BLUE)Installing development tools...$(NC)"
	go install github.com/cosmtrek/air@latest
	@echo "$(GREEN)Development tools installed!$(NC)"

# Test the application
.PHONY: test
test: check-deps ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	go test -v ./...
	@echo "$(GREEN)Tests completed!$(NC)"

# Test with coverage
.PHONY: test-coverage
test-coverage: check-deps ## Run tests with coverage report
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)Coverage report generated: coverage.html$(NC)"

# Format code
.PHONY: fmt
fmt: ## Format Go code
	@echo "$(BLUE)Formatting code...$(NC)"
	go fmt ./...
	@echo "$(GREEN)Code formatted!$(NC)"

# Lint code
.PHONY: lint
lint: ## Lint Go code (requires golangci-lint)
	@echo "$(BLUE)Linting code...$(NC)"
	@if which golangci-lint > /dev/null; then \
		golangci-lint run; \
		echo "$(GREEN)Linting completed!$(NC)"; \
	else \
		echo "$(YELLOW)golangci-lint not found. Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest$(NC)"; \
	fi

# Install linting tools
.PHONY: install-lint
install-lint: ## Install golangci-lint
	@echo "$(BLUE)Installing golangci-lint...$(NC)"
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "$(GREEN)golangci-lint installed!$(NC)"

# Clean build artifacts
.PHONY: clean
clean: ## Clean build artifacts and temporary files
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR)
	rm -f coverage.out coverage.html
	@echo "$(GREEN)Clean completed!$(NC)"

# Install Tesseract on macOS
.PHONY: install-tesseract-mac
install-tesseract-mac: ## Install Tesseract OCR on macOS using Homebrew
	@echo "$(BLUE)Installing Tesseract OCR on macOS...$(NC)"
	@if which brew > /dev/null; then \
		brew install tesseract; \
		echo "$(GREEN)Tesseract installed successfully!$(NC)"; \
	else \
		echo "$(RED)Homebrew not found. Please install Homebrew first: https://brew.sh$(NC)"; \
	fi

# Install Tesseract on Ubuntu/Debian
.PHONY: install-tesseract-ubuntu
install-tesseract-ubuntu: ## Install Tesseract OCR on Ubuntu/Debian
	@echo "$(BLUE)Installing Tesseract OCR on Ubuntu/Debian...$(NC)"
	sudo apt-get update
	sudo apt-get install -y tesseract-ocr
	@echo "$(GREEN)Tesseract installed successfully!$(NC)"

# Setup development environment
.PHONY: setup
setup: check-deps deps install-dev-tools ## Setup complete development environment
	@echo "$(GREEN)Development environment setup completed!$(NC)"
	@echo "$(YELLOW)You can now run 'make dev' to start development server$(NC)"

# Quick setup for production
.PHONY: setup-prod
setup-prod: check-deps deps build-prod ## Setup for production deployment
	@echo "$(GREEN)Production setup completed!$(NC)"
	@echo "$(YELLOW)Run 'make start' to start the application$(NC)"

# Show application info
.PHONY: info
info: ## Show application information
	@echo "$(BLUE)Application Information:$(NC)"
	@echo "Name: $(APP_NAME)"
	@echo "Main file: $(MAIN_FILE)"
	@echo "Build directory: $(BUILD_DIR)"
	@echo "Port: $(PORT)"
	@echo "Go version required: $(GO_VERSION)"
	@echo ""
	@echo "$(BLUE)Dependencies:$(NC)"
	@go list -m all 2>/dev/null || echo "Run 'make deps' first"

# Check if port is available
.PHONY: check-port
check-port: ## Check if the application port is available
	@echo "$(BLUE)Checking if port $(PORT) is available...$(NC)"
	@if lsof -Pi :$(PORT) -sTCP:LISTEN -t >/dev/null; then \
		echo "$(RED)Port $(PORT) is already in use:$(NC)"; \
		lsof -Pi :$(PORT) -sTCP:LISTEN; \
	else \
		echo "$(GREEN)Port $(PORT) is available!$(NC)"; \
	fi

# Kill process on port (if any)
.PHONY: kill-port
kill-port: ## Kill any process running on the application port
	@echo "$(BLUE)Killing process on port $(PORT)...$(NC)"
	@if lsof -Pi :$(PORT) -sTCP:LISTEN -t >/dev/null; then \
		lsof -ti:$(PORT) | xargs kill -9; \
		echo "$(GREEN)Process killed!$(NC)"; \
	else \
		echo "$(YELLOW)No process running on port $(PORT)$(NC)"; \
	fi

# Create .air.toml for development
.PHONY: create-air-config
create-air-config: ## Create air configuration for development
	@echo "$(BLUE)Creating air configuration...$(NC)"
	@cat > .air.toml << 'EOF'
root = "."
testdata_dir = "testdata"
tmp_dir = "tmp"

[build]
  args_bin = []
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ."
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "testdata"]
  exclude_file = []
  exclude_regex = ["_test.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "tpl", "tmpl", "html"]
  kill_delay = "0s"
  log = "build-errors.log"
  send_interrupt = false
  stop_on_root = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  time = false

[misc]
  clean_on_exit = false

[screen]
  clear_on_rebuild = false
EOF
	@echo "$(GREEN)Air configuration created: .air.toml$(NC)"

# All-in-one command for first-time setup
.PHONY: first-run
first-run: setup create-air-config ## Complete first-time setup and run
	@echo "$(GREEN)First-time setup completed!$(NC)"
	@echo "$(YELLOW)Starting development server...$(NC)"
	make dev