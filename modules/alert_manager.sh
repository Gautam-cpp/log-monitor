#!/bin/bash

# Alert management module

# Generate alert message
generate_alert() {
    local source="$1"
    local events="$2"
    
    # Create formatted alert message
    local alert="Critical events detected in $source at $(date):\n\n"
    
    # Process each event
    while IFS= read -r event; do
        # Skip empty lines
        [ -z "$event" ] && continue
        
        # Parse the event
        local parsed=$(parse_log_entry "$event")
        alert+="$parsed\n---\n"
    done <<< "$events"
    
    # Add footer
    alert+="\nThis is an automated alert from the Log Monitoring System."
    
    echo -e "$alert"
}

# Send notification via email
send_notification() {
    local recipient="$1"
    local subject="$2"
    local message="$3"
    
    # Validate inputs
    if [ -z "$recipient" ] || [ -z "$subject" ] || [ -z "$message" ]; then
        log_message "ERROR" "Missing parameters for notification"
        return 1
    fi
    
    # Send email using mail command
    echo -e "$message" | mail -s "$subject" "$recipient"
    
    # Check if mail command was successful
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}
