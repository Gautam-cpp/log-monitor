#!/usr/bin/env bats

# Load the modules to test
load '../modules/alert_manager.sh'
load '../modules/log_parser.sh'
load '../modules/utils.sh'

# Setup function runs before each test
setup() {
    # Create sample events for testing
    SAMPLE_EVENTS="Apr 1 10:30:15 server kernel: ERROR: Process crashed\nApr 1 10:35:22 server kernel: CRITICAL: Out of memory"
    
    # Mock the mail command for testing
    function mail() {
        echo "MAIL_CALLED: $*" > "$MAIL_OUTPUT"
        return 0
    }
    export -f mail
    
    # Create temporary files
    MAIL_OUTPUT="$(mktemp)"
    LOG_FILE="$(mktemp)"
}

# Teardown function runs after each test
teardown() {
    # Remove temporary files
    rm -f "$MAIL_OUTPUT"
    rm -f "$LOG_FILE"
    
    # Unset mock function
    unset -f mail
}

# Test generating alert
@test "generate_alert creates formatted message" {
    result=$(generate_alert "test_source" "$SAMPLE_EVENTS")
    [ -n "$result" ]
    [[ "$result" == *"Critical events detected in test_source"* ]]
    [[ "$result" == *"SEVERITY: ERROR"* ]]
    [[ "$result" == *"SEVERITY: CRITICAL"* ]]
    [[ "$result" == *"This is an automated alert"* ]]
}

# Test generating alert with empty events
@test "generate_alert handles empty events" {
    result=$(generate_alert "test_source" "")
    [ -n "$result" ]
    [[ "$result" == *"Critical events detected in test_source"* ]]
    [[ "$result" == *"This is an automated alert"* ]]
    [[ "$result" != *"SEVERITY"* ]]
}

# Test sending notification
@test "send_notification calls mail command" {
    run send_notification "admin@example.com" "Test Subject" "Test Message"
    [ "$status" -eq 0 ]
    
    # Check if mail was called with correct parameters
    cat "$MAIL_OUTPUT" | grep -q "MAIL_CALLED: -s Test Subject admin@example.com"
    [ "$?" -eq 0 ]
}

# Test sending notification with missing parameters
@test "send_notification fails with missing parameters" {
    # Missing recipient
    run send_notification "" "Test Subject" "Test Message"
    [ "$status" -eq 1 ]
    
    # Missing subject
    run send_notification "admin@example.com" "" "Test Message"
    [ "$status" -eq 1 ]
    
    # Missing message
    run send_notification "admin@example.com" "Test Subject" ""
    [ "$status" -eq 1 ]
}

# Test full alert workflow
@test "full alert workflow generates and sends notification" {
    # Mock functions to avoid external dependencies
    function parse_log_entry() {
        echo "TIMESTAMP: test_time"
        echo "SEVERITY: test_severity"
        echo "MESSAGE: test_message"
    }
    export -f parse_log_entry
    
    run generate_alert "test_source" "$SAMPLE_EVENTS"
    [ "$status" -eq 0 ]
    
    alert_message="$output"
    run send_notification "admin@example.com" "Test Alert" "$alert_message"
    [ "$status" -eq 0 ]
    
    # Unset mock function
    unset -f parse_log_entry
}
