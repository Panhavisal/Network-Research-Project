# AUPP Network Research Project 2024 V1.0

## Project Explanation:

This project entails setting up a system that initiates with the installation of required applications, ensuring avoidance of repeated installations. It performs an anonymity check of the network connection, alerting if non-anonymous, and revealing the spoofed country name if anonymous. It also accepts user-specified scan targets. Furthermore, the system can establish a remote SSH connection to retrieve server details and execute commands such as Whois and open port scans. Finally, it saves the gathered data into local files and maintains a log for auditing data collection activities.

Answer: 



## Full Script
```python
import subprocess
import sys

# Function to install packages
def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

# List of required packages
required_packages = ["paramiko", "requests", "geoip2"]

# Install required packages if not already installed
for package in required_packages:
    try:
        __import__(package)
    except ImportError:
        print(f"[ * ] Installing {package}...")
        install(package)

import paramiko
import requests
import geoip2.database
from getpass import getpass

def check_installations(apps):
    for app in apps:
        result = subprocess.run(['dpkg', '-l'], capture_output=True, text=True)
        if app not in result.stdout:
            print(f"[ * ] Installing {app}...")
            subprocess.run(['sudo', 'apt-get', 'install', '-y', app])
        else:
            print(f"[ # ] {app} is already installed.")

def check_anonymity():
    response = requests.get('https://check.torproject.org')
    if 'Congratulations. This browser is configured to use Tor.' in response.text:
        spoofed_ip = requests.get('https://ifconfig.me').text.strip()
        reader = geoip2.database.Reader('/usr/share/GeoIP/GeoLite2-Country.mmdb')
        response = reader.country(spoofed_ip)
        spoofed_country = response.country.name
        print(f"[ * ] You are anonymous. Connecting to the remote Server.")
        print(f"[ * ] Your Spoofed IP address is: {spoofed_ip}, Spoofed country: {spoofed_country}")
        return True
    else:
        print("[!] You are not anonymous. Please connect through Tor.")
        return False

def execute_remote_commands(remote_user, remote_host, remote_password, scan_target):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(remote_host, username=remote_user, password=remote_password)
    
    commands = [
        "echo '[ * ] Connecting to Remote Server:'",
        "uptime",
        f"echo 'IP address: $(hostname -I)'",
        f"echo 'Country: $(geoiplookup $(hostname -I) | awk -F \": \" '{{print $2}}')'",
        f"echo '[ * ] Whoising victim's address:'",
        f"whois {scan_target} > whois_{scan_target}.txt",
        f"echo '[ * ] Scanning victim's address:'",
        f"nmap {scan_target} > nmap_{scan_target}.txt"
    ]
    
    for command in commands:
        stdin, stdout, stderr = ssh.exec_command(command)
        print(stdout.read().decode())
        print(stderr.read().decode())
    
    sftp = ssh.open_sftp()
    sftp.get(f'whois_{scan_target}.txt', f'./whois_{scan_target}.txt')
    sftp.get(f'nmap_{scan_target}.txt', f'./nmap_{scan_target}.txt')
    sftp.close()
    
    ssh.close()

def main():
    apps = ["geoip-bin", "tor", "sshpass", "nipe"]
    check_installations(apps)
    
    if not check_anonymity():
        return
    
    scan_target = input("[? ] Specify a Domain/IP address to scan: ")
    remote_user = input("[? ] Enter the remote server username: ")
    remote_host = input("[? ] Enter the remote server IP address: ")
    remote_password = getpass("[? ] Enter the remote server password: ")

    execute_remote_commands(remote_user, remote_host, remote_password, scan_target)
    
    # Save the Whois and Nmap data into files
    print(f"[ 3 ] Whois data was saved into ./whois_{scan_target}.txt.")
    print(f"[ * ] Nmap scan was saved into ./nmap_{scan_target}.txt.")
    
    # Create a log and audit your data collecting
    log_file = "/var/log/nr.log"
    with open(log_file, "a") as log:
        log.write(f"{subprocess.getoutput('date')} - Whois data collected for: {scan_target}\n")
        log.write(f"{subprocess.getoutput('date')} - Nmap data collected for: {scan_target}\n")

if __name__ == "__main__":
    main()
```

## How to run?

```bash
#Linux
python3 NR.py
#Windows
python NR.py
```
Version 1.0
Make sure to replace placeholders with actual values (e.g., username, remote.server.ip, your_password) before running the script.
