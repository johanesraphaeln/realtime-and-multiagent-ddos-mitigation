under_attack = False

if ("$exec.system.cpu_info.total_cpu_usage" > 80):
  under_attack = True
elif ("$exec.system.memory_info.memory_percentage" > 80):
  under_attack = False
