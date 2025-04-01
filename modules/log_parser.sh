#!/bin/bash

# Log parsing module

# Acquire logs from specified source
acquire_logs() {
    local log_source="$1"
    local time_window="$2"
    
    # Default to last hour if not specified
    time_window=${time_window:-"1 hour ago"}
    
    # Use journalctl for systemd logs or cat for file logs
    if [[ "$log_source" == "systemd" ]]; then
        journalctl --since "$time_window"
    else
        # For regular log files, use grep with timestamp
        if [ -f "$log_source" ]; then
            current_date=$(date +"%b %d")
            grep "$current_date" "$log_source"
        else
            echo "Log source not found: $log_source"
            return 1
        fi
    fi
}

# Filter critical events based on patterns
filter_critical_events() {
    local log_source="$1"
    local patterns="$2"
    
    # Get logs from source
    local logs=$(acquire_logs "$log_source")
    
    # Check if logs were acquired successfully
    if [ $? -ne 0 ]; then
        log_message "ERROR" "Failed to acquire logs from $log_source"
        return 1
    fi
    
    # Filter logs based on patterns
    local filtered_logs=""
    for pattern in $patterns; do
        local pattern_matches=$(echo "$logs" | grep -i "$pattern")
        if [ -n "$pattern_matches" ]; then
            filtered_logs+="$pattern_matches\n"
        fi
    done
    
    # Remove duplicate entries
    echo -e "$filtered_logs" | sort | uniq
}

# Parse log entry into structured format
parse_log_entry() {
    local log_entry="$1"
    
    # Extract timestamp, severity, and message
    local timestamp=$(echo "$log_entry" | awk '{print $1" "$2" "$3}')
    local severity=$(echo "$log_entry" | grep -o -E 'ERROR|WARNING|CRITICAL|FATAL' | head -1)
    local message=$(echo "$log_entry" | cut -d' ' -f4-)
    
    # Default severity if not found
    severity=${severity:-"UNKNOWN"}
    
    # Return structured format
    echo "TIMESTAMP: $timestamp"
    echo "SEVERITY: $severity"
    echo "MESSAGE: $message"
}
