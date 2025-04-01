#!/bin/bash

# Log Monitoring System
# Version: 1.0
# Date: April 1, 2025

# Source modules
source "$(dirname "$0")/modules/config_handler.sh"
source "$(dirname "$0")/modules/log_parser.sh"
source "$(dirname "$0")/modules/alert_manager.sh"
source "$(dirname "$0")/modules/utils.sh"

# Initialize logging
LOG_FILE="/var/log/log_monitor.log"
CONFIG_FILE="/etc/log-monitor/config.conf"

# Main function
main() {
    log_message "INFO" "Starting log monitoring system"
    
    # Load configuration
    if ! load_config "$CONFIG_FILE"; then
        log_message "ERROR" "Failed to load configuration"
        exit 1
    fi
    
    # Get log sources from config
    log_sources=$(get_parameter "LOG_SOURCES")
    patterns=$(get_parameter "CRITICAL_PATTERNS")
    email_recipient=$(get_parameter "EMAIL_RECIPIENT")
    
    # Process each log source
    for source in $log_sources; do
        log_message "INFO" "Processing log source: $source"
        
        # Acquire and filter logs
        filtered_events=$(filter_critical_events "$source" "$patterns")
        
        # Check if critical events were found
        if [ -n "$filtered_events" ]; then
            log_message "WARNING" "Critical events detected in $source"
            
            # Generate and send alert
            alert=$(generate_alert "$source" "$filtered_events")
            if send_notification "$email_recipient" "Critical System Alert" "$alert"; then
                log_message "INFO" "Alert sent successfully to $email_recipient"
            else
                log_message "ERROR" "Failed to send alert to $email_recipient"
            fi
        else
            log_message "INFO" "No critical events detected in $source"
        fi
    done
    
    log_message "INFO" "Log monitoring completed successfully"
}

# Error handling with trap
trap 'log_message "ERROR" "Script execution interrupted"; exit 1' ERR INT TERM

# Execute main function
main
