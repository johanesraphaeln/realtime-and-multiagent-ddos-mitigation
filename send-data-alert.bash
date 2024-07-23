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

def get_system_resources():
    
    return {
        'cpu_info': get_cpu_info,
        'memory_info': get_memory_info,
        'disk_usage': get_disk_info
        'alert_info': get_alert_info
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