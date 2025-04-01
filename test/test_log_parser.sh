#!/usr/bin/env bats

# Load the modules to test
load '../modules/log_parser.sh'
load '../modules/utils.sh'

# Setup function runs before each test
setup() {
    # Create a temporary log file for testing
    TEST_LOG_FILE="$(mktemp)"
    
    # Add sample log entries
    echo "Apr 1 10:15:30 server kernel: INFO: System startup" > "$TEST_LOG_FILE"
    echo "Apr 1 10:20:45 server kernel: WARNING: High memory usage" >> "$TEST_LOG_FILE"
    echo "Apr 1 10:30:15 server kernel: ERROR: Process crashed" >> "$TEST_LOG_FILE"
    echo "Apr 1 10:35:22 server kernel: CRITICAL: Out of memory" >> "$TEST_LOG_FILE"
    echo "Apr 1 10:40:18 server kernel: INFO: Service restarted" >> "$TEST_LOG_FILE"
    
    # Set LOG_FILE for utils.sh
    LOG_FILE="$(mktemp)"
}

# Teardown function runs after each test
teardown() {
    # Remove temporary files
    rm -f "$TEST_LOG_FILE"
    rm -f "$LOG_FILE"
}

# Test acquiring logs
@test "acquire_logs retrieves logs from file" {
    run acquire_logs "$TEST_LOG_FILE"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 5 ]
}

# Test acquiring logs from non-existent file
@test "acquire_logs fails with non-existent file" {
    run acquire_logs "/nonexistent/file.log"
    [ "$status" -eq 1 ]
}

# Test filtering critical events
@test "filter_critical_events finds ERROR patterns" {
    result=$(filter_critical_events "$TEST_LOG_FILE" "ERROR")
    [ -n "$result" ]
    [[ "$result" == *"ERROR: Process crashed"* ]]
}

# Test filtering multiple patterns
@test "filter_critical_events finds multiple patterns" {
    result=$(filter_critical_events "$TEST_LOG_FILE" "ERROR CRITICAL")
    [ -n "$result" ]
    [[ "$result" == *"ERROR: Process crashed"* ]]
    [[ "$result" == *"CRITICAL: Out of memory"* ]]
}

# Test filtering with no matches
@test "filter_critical_events returns empty when no matches" {
    result=$(filter_critical_events "$TEST_LOG_FILE" "FATAL")
    [ -z "$result" ]
}

# Test parsing log entry
@test "parse_log_entry extracts correct components" {
    entry="Apr 1 10:30:15 server kernel: ERROR: Process crashed"
    result=$(parse_log_entry "$entry")
    [[ "$result" == *"TIMESTAMP: Apr 1 10:30:15"* ]]
    [[ "$result" == *"SEVERITY: ERROR"* ]]
    [[ "$result" == *"MESSAGE: server kernel: ERROR: Process crashed"* ]]
}

# Test parsing log entry with unknown severity
@test "parse_log_entry handles unknown severity" {
    entry="Apr 1 10:15:30 server kernel: INFO: System startup"
    result=$(parse_log_entry "$entry")
    [[ "$result" == *"SEVERITY: UNKNOWN"* ]]
}

# Test parsing empty log entry
@test "parse_log_entry handles empty input" {
    result=$(parse_log_entry "")
    [[ "$result" == *"TIMESTAMP: "* ]]
    [[ "$result" == *"SEVERITY: UNKNOWN"* ]]
    [[ "$result" == *"MESSAGE: "* ]]
}
