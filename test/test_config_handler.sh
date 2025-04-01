#!/usr/bin/env bats

# Load the modules to test
load '../modules/config_handler.sh'
load '../modules/utils.sh'

# Setup function runs before each test
setup() {
    # Create a temporary config file for testing
    TEST_CONFIG_FILE="$(mktemp)"
    echo "TEST_PARAM1=value1" > "$TEST_CONFIG_FILE"
    echo "TEST_PARAM2=value2" >> "$TEST_CONFIG_FILE"
    echo "LOG_SOURCES=/var/log/syslog /var/log/auth.log" >> "$TEST_CONFIG_FILE"
    
    # Set LOG_FILE for utils.sh
    LOG_FILE="$(mktemp)"
}

# Teardown function runs after each test
teardown() {
    # Remove temporary files
    rm -f "$TEST_CONFIG_FILE"
    rm -f "$LOG_FILE"
}

# Test loading configuration
@test "load_config loads configuration successfully" {
    run load_config "$TEST_CONFIG_FILE"
    [ "$status" -eq 0 ]
    [ "$TEST_PARAM1" = "value1" ]
    [ "$TEST_PARAM2" = "value2" ]
}

# Test loading non-existent configuration
@test "load_config fails with non-existent file" {
    run load_config "/nonexistent/file.conf"
    [ "$status" -eq 1 ]
}

# Test getting parameter
@test "get_parameter returns correct value" {
    load_config "$TEST_CONFIG_FILE"
    result=$(get_parameter "TEST_PARAM1")
    [ "$result" = "value1" ]
    
    result=$(get_parameter "TEST_PARAM2")
    [ "$result" = "value2" ]
}

# Test getting non-existent parameter
@test "get_parameter returns empty for non-existent parameter" {
    load_config "$TEST_CONFIG_FILE"
    result=$(get_parameter "NONEXISTENT_PARAM")
    [ -z "$result" ]
}

# Test saving parameter
@test "save_parameter adds new parameter" {
    run save_parameter "$TEST_CONFIG_FILE" "NEW_PARAM" "new_value"
    [ "$status" -eq 0 ]
    
    # Check if parameter was added
    grep -q "^NEW_PARAM=new_value$" "$TEST_CONFIG_FILE"
    [ "$?" -eq 0 ]
}

# Test updating existing parameter
@test "save_parameter updates existing parameter" {
    run save_parameter "$TEST_CONFIG_FILE" "TEST_PARAM1" "updated_value"
    [ "$status" -eq 0 ]
    
    # Check if parameter was updated
    grep -q "^TEST_PARAM1=updated_value$" "$TEST_CONFIG_FILE"
    [ "$?" -eq 0 ]
    
    # Make sure there's only one instance of the parameter
    count=$(grep -c "^TEST_PARAM1=" "$TEST_CONFIG_FILE")
    [ "$count" -eq 1 ]
}

# Test parameter with spaces
@test "get_parameter handles values with spaces" {
    load_config "$TEST_CONFIG_FILE"
    result=$(get_parameter "LOG_SOURCES")
    [ "$result" = "/var/log/syslog /var/log/auth.log" ]
}
