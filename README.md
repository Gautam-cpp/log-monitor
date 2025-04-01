# Log Monitoring System

A modular, efficient log monitoring system for Linux environments that scans system logs, filters critical events, and sends email alerts.

## Features

- Automated monitoring of multiple log sources
- Configurable pattern matching for critical event detection
- Email notifications for critical events
- Modular architecture with high cohesion and low coupling
- Comprehensive error handling and logging
- Performance optimized for large log files

## Requirements

- Bash 4.0+
- Linux-based operating system
- Mail utilities (mailutils, sendmail)
- Standard Linux utilities (grep, awk, sed)

## Installation

1. Clone this repository:
 - git clone https://github.com/gautam-cpp/log-monitor.git
 - cd log-monitor


2. Run the installation script:
 - sudo ./install.sh


3. Configure the system by editing the configuration file:
 - sudo nano /etc/log-monitor/config.conf


4. Test the installation:
 - sudo /opt/log-monitor/log_monitor.sh --test


## Usage

The log monitoring system runs automatically via cron job after installation. You can also run it manually:
sudo /opt/log-monitor/log_monitor.sh


### Command Line Options

- `--test`: Run in test mode without sending alerts
- `--verbose`: Enable detailed console output
- `--config=/path/to/config`: Use alternative configuration file

## Configuration

The system is configured via `/etc/log-monitor/config.conf`. Key settings include:

- `LOG_SOURCES`: Space-separated list of log files to monitor
- `CRITICAL_PATTERNS`: Patterns that trigger alerts
- `EMAIL_RECIPIENT`: Where to send alert emails
- `CHECK_INTERVAL`: How often to run checks (in minutes)

See the example configuration file for more options.

## Architecture

The system follows a modular design with the following components:

- `log_monitor.sh`: Main script that orchestrates the monitoring process
- `modules/config_handler.sh`: Manages configuration loading and parsing
- `modules/log_parser.sh`: Handles log acquisition and filtering
- `modules/alert_manager.sh`: Generates and sends alerts
- `modules/utils.sh`: Provides utility functions



## License

This project is licensed under the MIT License - see the LICENSE file for details.


