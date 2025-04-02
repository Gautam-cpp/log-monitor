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






## Task 1  Software Design Documentation for a Linux-Based Automation System

### Problem Selection: Automated Log Monitoring System

### Software Design Principles Application

## Abstraction

```
Log acquisition
Pattern matching and filtering
Alert generation
Notification delivery
```
## Encapsulation

```
acquire_logs(): Retrieves logs from specified sources
filter_critical_events(): Identifies critical events based on patterns
generate_alert(): Creates formatted alert messages
send_notification(): Delivers alerts via email
```

The system will be divided into independent, reusable modules:

## Modularity
The system will be divided into independent, reusable modules:


- log_parser.sh: Handles log acquisition and filtering
- alert_manager.sh: Manages alert generation and delivery
- config_handler.sh: Manages configuration settings
- utils.sh: Contains utility functions shared across modules
## Cohesion & Coupling

```
High Cohesion: Each module will focus on a single responsibility
Low Coupling: Modules will interact through well-defined interfaces, minimizing
dependencies
```
## Software Architecture Document SAD
## Data Flow Diagram DFD

![](./images/dataFlow.png)

## Class Diagram Bash Function Organization)
![](./images/diagram.png)

## Deployment Design
Installation instructions:


1)  Clone repository to /opt/log-monitor/
2) Run install.sh to set up dependencies:

```
 sudo apt-get install mailutils sendmail
 ```

3) Configure settings in /etc/log-monitor/config.conf
2) Set up cron job to run the monitor periodically:
```
*/10 * * * * /opt/log-monitor/run_monitor.sh
```
## Task 2  Shell Script Implementation with Modular Approach

### Main Script
- [log_monitor.sh](./log_monitor.sh)

### Modules
- [config_handler.sh](./modules/config_handler.sh)
- [log_parser.sh](./modules/log_parser.sh)
- [alert_manager.sh](./modules/alert_manager.sh)
- [utils.sh](./modules/utils.sh)


## Task 3  Implementation of Software Configuration Management SCM

## Git Repository Structure
![alt text](./images/image-2.png)

## Branching Strategy

- Main: Stable production code
- Develop: Integration branch for features
- Feature/X: Individual feature branches
- Bugfix/X: Bug fix branches
- Release/X.Y: Release preparation branches

## Git Workflow

### 1). Create feature branch from develop:
```
git checkout develop
git pull
git checkout -b feature/log-filtering
```
### 2). Implement changes and commit:
```
git add modules/log_parser.sh
git commit -m "Implement advanced log filtering with regex patterns"
```
### 3). Push feature branch and create pull request:
```
git push origin feature/log-filtering
```

### 4). After code review, merge to develop:
```
git checkout develop
git merge --no-ff feature/log-filtering
git push origin develop
```
### 5). Prepare release:
```
git checkout -b release/1.
# Version bumping and final testing
git checkout main
git merge --no-ff release/1.
git tag -a v1.0 -m "Version 1.0"
git push origin main --tags
```
## Version Control Strategy

```
Semantic versioning MAJOR.MINOR.PATCH
Version information stored in VERSION file
CHANGELOG.md updated with each release
Git tags for each release version
```
# Task 4 - Performance Testing and Risk Management

## Performance Testing

## Testing Tools


### 1). Shell Script Analysis:
- ShellCheck for static code analysis
- BATS (Bash Automated Testing System) for unit testing
### 2). Performance Monitoring:
- time command to measure execution time
- htop for CPU and memory usage
- iostat for I/O performance

## Test Cases

### 1) Unit Tests:
```
load '../modules/log_parser.sh'
load '../modules/utils.sh'@test "filter_critical_events finds ERROR patterns" {
result=$(filter_critical_events "test_data/sample.log" "ERROR")
[ -n "$result" ]
[[ "$result" == *"ERROR"* ]]
}
@test "parse_log_entry extracts correct components" {
entry="Apr 1 10:15:30 server kernel: ERROR: Out of memory"
result=$(parse_log_entry "$entry")
[[ "$result" == *"TIMESTAMP: Apr 1 10:15:30"* ]]
[[ "$result" == *"SEVERITY: ERROR"* ]]
[[ "$result" == *"MESSAGE: server kernel: ERROR: Out of memory"* ]]
}
```
### 2) Performance Tests:
```

# Measure execution time
time ./log_monitor.sh
# Monitor resource usage
/usr/bin/time -v ./log_monitor.sh
```
### 3). Load Testing:
- Test with large log files (>1GB)
- Test with high-frequency log generation

## Risk Management
### Technical Risks
![alt text](./images/img1.png)
### Operational Risks
![alt text](./images/image-1.png)


## Risk Mitigation Strategies


### Defensive Programming:
- Input validation for all parameters
- Comprehensive error handling
- Graceful degradation when components fail
### Monitoring and Alerting:
- Self-monitoring capabilities
- Health check endpoints
- Performance metrics collection
### Documentation and Training:
- Detailed installation and troubleshooting guides
- Regular knowledge sharing sessions
- Incident response procedures
### Continuous Improvement:
- Regular code reviews
- Automated testing in CI/CD pipeline
- Post-incident analysis and improvements



## Contributors ✨

Thanks to these amazing people who contributed to this project:

| Contributor | Profile |
|------------|---------|
| [Sumedhvats](https://github.com/Sumedhvats) | <a href="https://github.com/Sumedhvats"><img src="https://github.com/Sumedhvats.png" width="50" height="50"></a> |
| [Mohit137c](https://github.com/Mohit137c) | <a href="https://github.com/Mohit137c"><img src="https://github.com/Mohit137c.png" width="50" height="50"></a> |
| [Vivek-Anand727](https://github.com/Vivek-Anand727) | <a href="https://github.com/Vivek-Anand727"><img src="https://github.com/Vivek-Anand727.png" width="50" height="50"></a> |



