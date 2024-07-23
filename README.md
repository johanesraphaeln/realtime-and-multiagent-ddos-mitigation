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
