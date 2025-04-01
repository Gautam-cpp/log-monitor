#!/bin/bash

# Utility functions module

# Log message to file
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Ensure LOG_FILE is defined
    if [ -z "$LOG_FILE" ]; then
        LOG_FILE="/var/log/log_monitor.log"
    fi
    
    # Create log directory if it doesn't exist
    local log_dir=$(dirname "$LOG_FILE")
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi
    
    # Write to log file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Print to console if verbose mode is enabled
    if [ "${VERBOSE:-0}" -eq 1 ]; then
        echo "[$timestamp] [$level] $message"
    fi
}

# Handle errors
handle_error() {
    local error_code="$1"
    local error_message="$2"
    
    log_message "ERROR" "Error $error_code: $error_message"
    
    # Send error notification if configured
    if [ -n "${ERROR_NOTIFICATION_EMAIL:-}" ]; then
        send_notification "$ERROR_NOTIFICATION_EMAIL" "Log Monitor Error" "Error $error_code: $error_message"
    fi
    
    # Exit with error code
    exit "$error_code"
}

# Validate input parameters
validate_input() {
    local input="$1"
    local pattern="$2"
    local error_message="$3"
    
    if ! echo "$input" | grep -q "$pattern"; then
        log_message "ERROR" "$error_message"
        return 1
    fi
    
    return 0
}
