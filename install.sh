#!/bin/bash

# Log Monitoring System Installer
# Version: 1.0
# Date: April 1, 2025

# Exit on any error
set -e

# Configuration
INSTALL_DIR="/opt/log-monitor"
CONFIG_DIR="/etc/log-monitor"
LOG_DIR="/var/log/log-monitor"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display messages
print_message() {
    local color_code="$1"
    local message="$2"
    echo -e "\e[${color_code}m${message}\e[0m"
}

# Function to check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        print_message "31" "Error: This script must be run as root"
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    print_message "34" "Installing dependencies..."
    
    # Detect package manager
    if command -v apt-get &>/dev/null; then
        apt-get update
        apt-get install -y mailutils sendmail grep sed awk coreutils
    elif command -v yum &>/dev/null; then
        yum install -y mailx sendmail grep sed gawk coreutils
    elif command -v dnf &>/dev/null; then
        dnf install -y mailx sendmail grep sed gawk coreutils
    else
        print_message "31" "Error: Unsupported package manager. Please install dependencies manually."
        exit 1
    fi
    
    print_message "32" "Dependencies installed successfully"
}

# Function to create directories
create_directories() {
    print_message "34" "Creating directories..."
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$LOG_DIR"
    
    print_message "32" "Directories created successfully"
}

# Function to copy files
copy_files() {
    print_message "34" "Copying files..."
    
    # Copy main script
    cp "$SCRIPT_DIR/log_monitor.sh" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/log_monitor.sh"
    
    # Copy modules
    mkdir -p "$INSTALL_DIR/modules"
    cp "$SCRIPT_DIR/modules/"*.sh "$INSTALL_DIR/modules/"
    chmod +x "$INSTALL_DIR/modules/"*.sh
    
    # Copy configuration
    if [ ! -f "$CONFIG_DIR/config.conf" ]; then
        cp "$SCRIPT_DIR/config/config.conf.example" "$CONFIG_DIR/config.conf"
        print_message "33" "Created default configuration file at $CONFIG_DIR/config.conf"
        print_message "33" "Please review and update the configuration file"
    else
        print_message "33" "Configuration file already exists, skipping..."
    fi
    
    print_message "32" "Files copied successfully"
}

# Function to set up cron job
setup_cron() {
    print_message "34" "Setting up cron job..."
    
    # Create cron file
    cat > /etc/cron.d/log-monitor << EOF
# Run log monitor every 10 minutes
*/10 * * * * root $INSTALL_DIR/log_monitor.sh > /dev/null 2>&1
EOF
    
    # Reload cron service if systemd is available
    if command -v systemctl &>/dev/null; then
        systemctl restart cron.service || systemctl restart crond.service || true
    fi
    
    print_message "32" "Cron job set up successfully"
}

# Function to set permissions
set_permissions() {
    print_message "34" "Setting permissions..."
    
    # Set ownership
    chown -R root:root "$INSTALL_DIR"
    chown -R root:root "$CONFIG_DIR"
    
    # Set directory permissions
    chmod 755 "$INSTALL_DIR"
    chmod 755 "$CONFIG_DIR"
    chmod 755 "$LOG_DIR"
    
    # Set file permissions
    chmod 644 "$CONFIG_DIR/config.conf"
    chmod 644 /etc/cron.d/log-monitor
    
    print_message "32" "Permissions set successfully"
}

# Function to test installation
test_installation() {
    print_message "34" "Testing installation..."
    
    if [ -x "$INSTALL_DIR/log_monitor.sh" ]; then
        "$INSTALL_DIR/log_monitor.sh" --test
        if [ $? -eq 0 ]; then
            print_message "32" "Installation test successful"
        else
            print_message "31" "Installation test failed"
            exit 1
        fi
    else
        print_message "31" "Error: Main script not found or not executable"
        exit 1
    fi
}

# Main installation process
main() {
    print_message "36" "=== Log Monitoring System Installer ==="
    
    # Check if running as root
    check_root
    
    # Install dependencies
    install_dependencies
    
    # Create directories
    create_directories
    
    # Copy files
    copy_files
    
    # Set permissions
    set_permissions
    
    # Set up cron job
    setup_cron
    
    # Test installation
    test_installation
    
    print_message "32" "=== Installation completed successfully ==="
    print_message "33" "The log monitoring system is now installed and running"
    print_message "33" "Configuration file: $CONFIG_DIR/config.conf"
    print_message "33" "Log file: $LOG_DIR/log_monitor.log"
}

# Run the main installation process
main
