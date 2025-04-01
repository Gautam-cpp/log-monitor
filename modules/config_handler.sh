#!/bin/bash

# Configuration handling module

# Load configuration from file
load_config() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        return 1
    fi
    
    # Export all variables from config file
    set -a
    source "$config_file"
    set +a
    
    return 0
}

# Get parameter from loaded configuration
get_parameter() {
    local param_name="$1"
    local param_value="${!param_name}"
    
    echo "$param_value"
}

# Save parameter to configuration
save_parameter() {
    local config_file="$1"
    local param_name="$2"
    local param_value="$3"
    
    # Check if parameter exists
    if grep -q "^$param_name=" "$config_file"; then
        # Update existing parameter
        sed -i "s/^$param_name=.*/$param_name=$param_value/" "$config_file"
    else
        # Add new parameter
        echo "$param_name=$param_value" >> "$config_file"
    fi
}
