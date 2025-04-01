#!/usr/bin/env bats

# Load the module to test
load '../modules/utils.sh'

# Setup function runs before each test
setup() {
    # Create temporary log file
    LOG_FILE="$(mktemp)"
    
    # Set verbose mode off by default
    VERBOSE=0
}

# Teardown function runs after each test
teardown() {
    # Remove temporary files
    rm -f "$LOG_FILE"
}

# Test logging message
@test "log_message writes to log file" {
    run log_message "INFO" "Test message"
    [ "$status" -eq 0 ]
    
    # Check if message was written to log file
    grep -q "\[INFO\] Test message" "$LOG_FILE"
    [ "$?" -eq 0 ]
}

# Test logging with different levels
@test "log_message handles different log levels" {
    log_message "INFO" "Info message"
    log_message "WARNING" "Warning message"
    log_message "ERROR" "Error message"
    
    # Check if all messages were logged
    grep -q "\[INFO\] Info message" "$LOG_FILE"
    [ "$?" -eq 0 ]
    
    grep -q "\[WARNING\] Warning message" "$LOG_FILE"
    [ "$?" -eq 0 ]
    
    grep -q "\[ERROR\] Error message" "$LOG_FILE"
    [ "$?" -eq 0 ]
}

# Test verbose mode
@test "log_message respects verbose mode" {
    # Capture stdout
    VERBOSE=1
    run log_message "INFO" "Verbose message"
    
    # Check if message was printed to stdout
    [[ "$output" == *"[INFO] Verbose message"* ]]
}

# Test error handling
@test "handle_error logs error and exits" {
    # We need to run this in a subshell to avoid exiting the test
    run bash -c "source '../modules/utils.sh'; LOG_FILE='$LOG_FILE'; handle_error 42 'Test error'"
    
    # Check exit code
    [ "$status" -eq 42 ]
    
    # Check if error was logged
    grep -q "\[ERROR\] Error 42: Test error" "$LOG_FILE"
    [ "$?" -eq 0 ]
}


# Test error notification
@test "handle_error sends notification if configured" {
    # Mock send_notification function
    function send_notification() {
        echo "NOTIFICATION_SENT: $*" > "$NOTIFICATION_OUTPUT"
        return 0
    }
    export -f send_notification
    
    # Create temporary file for notification output
    NOTIFICATION_OUTPUT="$(mktemp)"
    
    # Set notification email
    ERROR_NOTIFICATION_EMAIL="admin@example.com"
    
    # Run handle_error in a subshell
    run bash -c "source '../modules/utils.sh'; LOG_FILE='$LOG_FILE'; ERROR_NOTIFICATION_EMAIL='$ERROR_NOTIFICATION_EMAIL'; send_notification() { echo \"NOTIFICATION_SENT: \$*\" > '$NOTIFICATION_OUTPUT'; return 0; }; handle_error 42 'Test error'"
    
    # Check if notification was sent
    cat "$NOTIFICATION_OUTPUT" | grep -q "NOTIFICATION_SENT: admin@example.com Log Monitor Error Error 42: Test error"
    [ "$?" -eq 0 ]
    
    # Clean up
    rm -f "$NOTIFICATION_OUTPUT"
}

# Test input validation
@test "validate_input validates against pattern" {
    # Valid input
    run validate_input "test123" "^test[0-9]+$" "Invalid input"
    [ "$status" -eq 0 ]
    
    # Invalid input
    run validate_input "invalid" "^test[0-9]+$" "Invalid input"
    [ "$status" -eq 1 ]
    
    # Check if error was logged
    grep -q "\[ERROR\] Invalid input" "$LOG_FILE"
    [ "$?" -eq 0 ]
}

# Test creating log directory
@test "log_message creates log directory if needed" {
    # Set log file in a non-existent directory
    temp_dir="$(mktemp -d)"
    non_existent_dir="$temp_dir/logs"
    LOG_FILE="$non_existent_dir/test.log"
    
    # Log a message
    run log_message "INFO" "Test directory creation"
    [ "$status" -eq 0 ]
    
    # Check if directory was created
    [ -d "$non_existent_dir" ]
    
    # Check if log file was created
    [ -f "$LOG_FILE" ]
    
    # Clean up
    rm -rf "$temp_dir"
}
