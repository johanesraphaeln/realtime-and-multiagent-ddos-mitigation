# Detection and Prevention System to Handle DDoS Attack in Realtime and Multi Agent

## Overview

This project aims to design and implement a real-time, multi-agent system for detecting and preventing Distributed Denial of Service (DDoS) attacks. The system integrates various open-source security tools to provide comprehensive protection against DDoS attacks.

## System Design

### System Architecture

![System Flow Diagram](system-architecture.png)

The proposed security system is developed within a Linux environment, specifically using the Ubuntu Server distribution. The architecture consists of four virtual machines (VMs):

- **2 VMs as SIEM Agents**
- **1 VM as SIEM Manager and Agent**
- **1 VM as SOAR**

### Security Tools

1. **Snort (IDS)**

   - An open-source Intrusion Detection System (IDS) used as a sensor and analyzer for network traffic.
   - Capable of real-time traffic analysis and protocol analysis to detect various types of attacks.

2. **Wazuh (SIEM)**

   - An open-source Security Information and Event Management (SIEM) tool that collects and analyzes security alerts.
   - Integrates seamlessly with Snort to receive alerts and provides active response capabilities through custom scripts.

3. **Shuffle (SOAR)**

   - An open-source Security Orchestration, Automation, and Response (SOAR) platform.
   - Facilitates orchestration, automation, and response to security incidents with ease of operation and a large community support.

4. **Discord (SOC Communication)**
   - Used as a communication tool to notify the Security Operations Center (SOC) via webhooks.
   - Selected for its easy integration with other tools.

### System Flow

The system flow is designed to handle DDoS attacks through a structured integration of the above-mentioned tools, ensuring real-time detection and prevention.

![System Flow Diagram](system-architecture.png)

## Table of Contents

- [Detection and Prevention System to Handle DDoS Attack in Realtime and Multi Agent](#detection-and-prevention-system-to-handle-ddos-attack-in-realtime-and-multi-agent)
  - [Overview](#overview)
  - [System Design](#system-design)
    - [System Architecture](#system-architecture)
    - [Security Tools](#security-tools)
    - [System Flow](#system-flow)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Initial Setup](#initial-setup)
    - [1. Create Snort Rules](#1-create-snort-rules)
    - [2. Create Custom Active Response Script for Wazuh](#2-create-custom-active-response-script-for-wazuh)
    - [3. Create Notification Text Channel for SOC on Discord](#3-create-notification-text-channel-for-soc-on-discord)
    - [4. Create Shuffle Playbook](#4-create-shuffle-playbook)
      - [Get Wazuh Alerts](#get-wazuh-alerts)
    - [Authenticate Wazuh](#authenticate-wazuh)
      - [Run System Resource Check](#run-system-resource-check)
      - [Determine Alert](#determine-alert)
      - [Notify SOC Team for False Positive](#notify-soc-team-for-false-positive)
      - [Notify SOC Team for True Positive](#notify-soc-team-for-true-positive)
      - [Block IP in All Wazuh-Agents](#block-ip-in-all-wazuh-agents)
    - [5. Configure Security Tools](#5-configure-security-tools)

## Introduction

To effectively handle DDoS attacks, it is essential to integrate multiple security tools and establish a structured workflow. This ensures a comprehensive response from detecting the attack to notifying the Security Operations Center (SOC) and executing automated responses via Security Orchestration, Automation, and Response (SOAR) systems.

## Initial Setup

### 1. Create Snort Rules

Define rules in Snort to detect malicious traffic based on specified patterns. Note that legitimate traffic may also be flagged.

```bash
alert tcp any any -> any 80 (msg:"Possible DDoS attack"; flags:S;)
```

### 2. Create Custom Active Response Script for Wazuh

Use Python's psutil library to monitor system resources. The script is placed in each Wazuh agent's directory in /ossec-agent/active-response/bin and configured in the ossec.conf file on the Wazuh manager.

```python
#!/usr/bin/env python

import psutil # type: ignore
import requests # type: ignore
import json

# Replace 'YOUR_WEBHOOK_URL' with the actual webhook URL
WEBHOOK_URL = 'YOUR_WEBHOOK_URL'

def get_memory_info():
    return {
        "total_memory": psutil.virtual_memory().total / (1024.0 ** 3),
        "available_memory": psutil.virtual_memory().available / (1024.0 ** 3),
        "used_memory": psutil.virtual_memory().used / (1024.0 ** 3),
        "memory_percentage": psutil.virtual_memory().percent
    }

def get_cpu_info():
    return {
        "physical_cores": psutil.cpu_count(logical=False),
        "total_cores": psutil.cpu_count(logical=True),
        "processor_speed": psutil.cpu_freq().current,
        "cpu_usage_per_core": dict(enumerate(psutil.cpu_percent(percpu=True, interval=1))),
        "total_cpu_usage": psutil.cpu_percent(interval=1)
    }

def get_disk_info():
    partitions = psutil.disk_partitions()
    disk_info = {}
    for partition in partitions:
        partition_usage = psutil.disk_usage(partition.mountpoint)
        disk_info[partition.mountpoint] = {
            "total_space": partition_usage.total / (1024.0 ** 3),
            "used_space": partition_usage.used / (1024.0 ** 3),
            "free_space": partition_usage.free / (1024.0 ** 3),
            "usage_percentage": partition_usage.percent
        }
    return disk_info

def get_alert_info():
   """
   Retrieve the alert information from the arguments that came from Shuffle-Wazuh Custom AR
   """

def get_under_attack():
   """
   Create a determination if the system is under attack based on the CPU and Memory usage information
   """

def get_system_resources():

    return {
        'cpu_info': get_cpu_info(),
        'memory_info': get_memory_info(),
        'disk_usage': get_disk_info(),
        'alert_info': get_alert_info(),
        'under_attack': get_under_attack()
    }

def send_to_webhook(data):
    headers = {'Content-Type': 'application/json'}
    payload = {'text': json.dumps(data, indent=4)}

    response = requests.post(WEBHOOK_URL, headers=headers, json=payload)

    if response.status_code == 200:
        print("Data sent successfully to the webhook.")
    else:
        print(f"Failed to send data. Status code: {response.status_code}")

if __name__ == "__main__":
    system_resources = get_system_resources()
    send_to_webhook(system_resources)


# https://umeey.medium.com/system-monitoring-made-easy-with-pythons-psutil-library-4b9add95a443
```

After you create the active response script, configure it by executing this command to change its ownership and permissions

```bash
sudo chmod 750 /var/ossec/active-response/bin/custom-ar.py
sudo chown root:wazuh /var/ossec/active-response/bin/[your-file-name].py
sudo systemctl restart wazuh-agent
```

Finally add this command and active-response to the Wazuh Server in /var/ossec/etc/ossec.conf and restart the Wazuh Manager

```bash
<command>
   <name>check-system-resource</name>
   <executable>check-system-resource</executable>
   <extra_args>args</extra_args>
</command>

<active-response>
   <disabled>no</disabled>
   <command>check-system-resource</command>
   <location>local</location>
   <rules_id>5710</rules_id>
   <timeout>60</timeout>
</active_response>

<localfile>
   <log_format>snort-full</log_format>
   <location>/var/log/snort/snort.alert.fast</location>
</localfile>

<integration>
   <name>shuffle</name>
   <hook_url>http://IP:4001/api/v1/hooks/webhook_id</hook_url>
   <group>ids</group>
   <alert_format>json</alert_format>
</integration>
```

```bash
sudo systemctl restart wazuh-manager
```

### 3. Create Notification Text Channel for SOC on Discord

Set up a Discord server to notify the SOC using integrated webhooks.

### 4. Create Shuffle Playbook

Design a playbook in Shuffle to orchestrate the response to DDoS attacks. Integrate security tools via webhooks to receive alert data and system resource information, and use Wazuh's API to trigger custom active responses.

#### Get Wazuh Alerts

```plaintext
Use HTTP Webhook and configured it in the Wazuh Manager
```

### Authenticate Wazuh

```plaintext
Use the credentials given by Wazuh Manager and place it in WAZUH to get the token authentication
```

#### Run System Resource Check

After we get the token authentication, we run the Custom Active Response from Shuffle that would be executed in the corresponding Wazuh Agent

```json
{
  "command": "!check-system-resource",
  "custom": true,
  "arguments": [
    "$exec.text",
    "$exec.all_fields.predecoder.timestamp",
    "$exec.all_fields.data.srcip",
    "$exec.all_fields.data.dstip",
    "$exec.all_fields.agent.id",
    "$exec.all_fields.agent.name",
    "$exec.all_fields.agent.ip",
    "$authenticate_wazuh_manager.body"
  ]
}
```

#### Determine Alert

Based on the system resource check, it will be return the information with POST request to newly configured Shuffle Webhook

```json
{
  "system": {
    "cpu_info": {
      "physical_cores": 1,
      "total_cores": 1,
      "processor_speed": 3110.398,
      "cpu_usage_per_core": {
        "0": 0
      },
      "total_cpu_usage": 2.2
    },
    "memory_info": {
      "total_memory": 1.9137382507324219,
      "available_memory": 0.3784217834472656,
      "used_memory": 1.3662834167480469,
      "memory_percentage": 80.2
    },
    "disk_info": {
      "total_space": 48.41845703125,
      "used_space": 15.201675415039062,
      "free_space": 30.72635269165039,
      "usage_percentage": 33.1
    },
    "alert_info": {
      "text": "01/09-04:46:00.331636 [] [1:100002:1] Possible SYN DDoS [] [Priority: 0] {TCP} 142.12.76.41:39688 -> 192.168.1.14:0",
      "timestamp": "01/09-04:46:00.331636",
      "srcip": "142.12.76.41",
      "dstip": "192.168.1.14:0",
      "agent_id": "002",
      "agent_name": "wazuhagent2-VirtualBox",
      "agent_ip": "192.168.1.14",
      "api_key": "eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ3YXp1aCIsImF1ZCI6IldhenVoIEFQSSBSRVNUIiwibmJmIjoxNzA0NzUwMzgyLCJleHAiOjE3MDQ3NTEyODIsInN1YiI6IndhenVoLXd1aSIsInJ1bl9hcyI6ZmFsc2UsInJiYWNfcm9sZXMiOlsxXSwicmJhY19tb2RlIjoid2hpdGUifQ.APViDsgPgluDlFKCqOud_iC20xAsvj13HoJcbI6Bxucdx3AqkMMXc-6aMo0UtgFVg68ZE_Zc7DNtcrpwvgMGapzIAZDy1qqhHJlweny-Nfzm9pehkQY8po-PCWU6vaI0T0OB37Ngko-uW-9mp_Q3K-fvXzwL7rkY3SdQyzEC2GpCoJ9G"
    },
    "under_attack": true
  }
}
```

With the information on "under_attack" field, use IF statement in Shuffle to create a different path to be executed
```python
if ("$exec.system.cpu_info.total_cpu_usage" > 80):
  under_attack = True
elif ("$exec.system.memory_info.memory_percentage" > 80):
  under_attack = False

```

#### Notify SOC Team for False Positive
```json
{
  "content": "Alert: DDoS false Alarm has occurred!",
  "embeds": [
    {
      "title": "Alert Details",
      "description": "$exec.system.alert_info.text",
      "color": 16711680,
      "fields": [
        {
          "name": "Timestamp",
          "value": "$exec.system.alert_info.timestamp"
        },
        {
          "name": "Details",
          "value": "SourceIP: $exec.system.alert_info.srcip\nDestinationIP: $exec.system.alert_info.dstip"
        },
        {
          "name": "Agent",
          "value": "ID: $exec.system.alert_info.agent_id\nName: $exec.system.alert_info.agent_name\nIP: $exec.system.alert_info.agent_ip"
        }
      ]
    },
    {
      "title": "System Information",
      "description": "System details for reference:",
      "color": 65280,
      "fields": [
        {
          "name": "Memory",
          "value": "Total: $exec.system.memory_info.total_memory GB\nUsed: $exec.system.memory_info.used_memory GB\nFree: $exec.system.memory_info.available_memory GB\nUsage: $exec.system.memory_info.memory_percentage%"
        },
        {
          "name": "CPU",
          "value": "Physical Cores: $exec.system.cpu_info.physical_cores\nTotal Cores: $exec.system.cpu_info.total_cores\nProcessor Speed: $exec.system.cpu_info.processor_speed MHz\nTotal CPU Usage: $exec.system.cpu_info.total_cpu_usage%"
        },
        {
          "name": "Disk",
          "value": "Total Space: $exec.system.disk_info.total_space GB\nUsed Space: $exec.system.disk_info.used_space GB\nFree Space: $exec.system.disk_info.free_space GB\nUsage: $exec.system.disk_info.usage_percentage%"
        }
      ]
    },
    {
      "title": "Action",
      "description": "Further analysis is strongly recommended!",
      "color": 65280
    }
  ]
}
```

#### Notify SOC Team for True Positive

```json
{
  "content": "Alert: A DDoS attack has occurred!",
  "embeds": [
    {
      "title": "Alert Details",
      "description": "$exec.system.alert_info.text",
      "color": 16711680,
      "fields": [
        {
          "name": "Timestamp",
          "value": "$exec.system.alert_info.timestamp"
        },
        {
          "name": "Details",
          "value": "SourceIP: $exec.system.alert_info.srcip\nDestinationIP: $exec.system.alert_info.dstip"
        },
        {
          "name": "Agent",
          "value": "ID: $exec.system.alert_info.agent_id\nName: $exec.system.alert_info.agent_name\nIP: $exec.system.alert_info.agent_ip"
        }
      ]
    },
    {
      "title": "System Information",
      "description": "System details for reference:",
      "color": 65280,
      "fields": [
        {
          "name": "Memory",
          "value": "Total: $exec.system.memory_info.total_memory GB\nUsed: $exec.system.memory_info.used_memory GB\nFree: $exec.system.memory_info.available_memory GB\nUsage: $exec.system.memory_info.memory_percentage%"
        },
        {
          "name": "CPU",
          "value": "Physical Cores: $exec.system.cpu_info.physical_cores\nTotal Cores: $exec.system.cpu_info.total_cores\nProcessor Speed: $exec.system.cpu_info.processor_speed MHz\nTotal CPU Usage: $exec.system.cpu_info.total_cpu_usage%"
        },
        {
          "name": "Disk",
          "value": "Total Space: $exec.system.disk_info.total_space GB\nUsed Space: $exec.system.disk_info.used_space GB\nFree Space: $exec.system.disk_info.free_space GB\nUsage: $exec.system.disk_info.usage_percentage%"
        }
      ]
    },
    {
      "title": "Action",
      "description": "The Source IP has been Blocked in All Agents",
      "color": 65280
    }
  ]
}
```

#### Block IP in All Wazuh-Agents
If the system's under_attack is True, then run this script that will be configured in all Wazuh Agents
```json
{
  "alert": {
    "data": {
      "srcip": "$exec.system.alert_info.srcip"
    }
  },
  "command": "!firewall-drop"
}
```

### 5. Configure Security Tools

Configure Wazuh to read Snort alerts and forward them to Shuffle. Set up webhooks in Shuffle to send summarized notifications to the SOC's text channel on Discord.
