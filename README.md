# Network Research Project 2024 V1.0

## Project Explanation:

This project entails setting up a system that initiates with the installation of required applications, ensuring avoidance of repeated installations. It performs an anonymity check of the network connection, alerting if non-anonymous, and revealing the spoofed country name if anonymous. It also accepts user-specified scan targets. Furthermore, the system can establish a remote SSH connection to retrieve server details and execute commands such as Whois and open port scans. Finally, it saves the gathered data into local files and maintains a log for auditing data collection activities.

Answer: 


### Step 1: Install Required Applications


Create the Script File and Open a text editor and create a new script file named **NR.sh.**

```bash
#!/bin/bash

# Check and install necessary applications
apps=("geoip-bin" "tor" "sshpass" "nipe")

for app in "${apps[@]}"
do
    if ! dpkg -l | grep -q "$app"; then
        echo "[ * ] Installing $app..."
        sudo apt-get install -y $app
    else
        echo "[ # ] $app is already installed."
    fi
done
````

### Step 2: Check Anonymity


Add Anonymity Check

```bash
# Check network anonymity
if [[ $(curl -s https://check.torproject.org | grep -o "Congratulations. This browser is configured to use Tor.") ]]; then
    spoofed_ip=$(curl -s ifconfig.me)
    spoofed_country=$(geoiplookup $spoofed_ip | awk -F ": " '{print $2}')
    echo "[ * ] You are anonymous. Connecting to the remote Server."
    echo "[ * ] Your Spoofed IP address is: $spoofed_ip, Spoofed country: $spoofed_country"
else
    echo "[!] You are not anonymous. Please connect through Tor."
    exit 1
fi
```

### Step 3: Accept User-Specified Scan Targets

```bash
# Accept user input for the address to scan
read -p "[? ] Specify a Domain/IP address to scan: " scan_target
```


### Step 4: Establish SSH Connection and Execute Commands

Add SSH Connection and Command Execution

```bash
# Remote server details
remote_user="username" # Change to your remote server username
remote_host="remote.server.ip" # Change to your remote server IP

# Connect to the remote server and execute commands
sshpass -p 'your_password' ssh -o StrictHostKeyChecking=no $remote_user@$remote_host << EOF
echo "[ * ] Connecting to Remote Server:"
uptime
echo "IP address: $(hostname -I)"
echo "Country: $(geoiplookup $(hostname -I) | awk -F ": " '{print $2}')"

echo "[ * ] Whoising victim's address:"
whois $scan_target > whois_$scan_target.txt

echo "[ * ] Scanning victim's address:"
nmap $scan_target > nmap_$scan_target.txt
EOF

# Copy the results back to the local machine
scp $remote_user@$remote_host:~/whois_$scan_target.txt ~/Desktop/nipe/whois_$scan_target.txt
scp $remote_user@$remote_host:~/nmap_$scan_target.txt ~/Desktop/nipe/nmap_$scan_target.txt
```

### Step 5: Save Gathered Data and Maintain Logs

Add Data Saving and Logging

```bash
# Save the Whois and Nmap data into files
echo "[ 3 ] Whois data was saved into /home/kali/Desktop/nipe/whois_$scan_target.txt."
echo "[ * ] Nmap scan was saved into /home/kali/Desktop/nipe/nmap_$scan_target.txt."

# Create a log and audit your data collecting
log_file="/var/log/nr.log"
echo "$(date) - Whois data collected for: $scan_target" >> $log_file
echo "$(date) - Nmap data collected for: $scan_target" >> $log_file
```

## Full Script
```bash
#!/bin/bash

# Check and install necessary applications
apps=("geoip-bin" "tor" "sshpass" "nipe")

for app in "${apps[@]}"
do
    if ! dpkg -l | grep -q "$app"; then
        echo "[ * ] Installing $app..."
        sudo apt-get install -y $app
    else
        echo "[ # ] $app is already installed."
    fi
done

# Check network anonymity
if [[ $(curl -s https://check.torproject.org | grep -o "Congratulations. This browser is configured to use Tor.") ]]; then
    spoofed_ip=$(curl -s ifconfig.me)
    spoofed_country=$(geoiplookup $spoofed_ip | awk -F ": " '{print $2}')
    echo "[ * ] You are anonymous. Connecting to the remote Server."
    echo "[ * ] Your Spoofed IP address is: $spoofed_ip, Spoofed country: $spoofed_country"
else
    echo "[!] You are not anonymous. Please connect through Tor."
    exit 1
fi

# Accept user input for the address to scan
read -p "[? ] Specify a Domain/IP address to scan: " scan_target

# Remote server details
remote_user="username" # Change to your remote server username
remote_host="remote.server.ip" # Change to your remote server IP

# Connect to the remote server and execute commands
sshpass -p 'your_password' ssh -o StrictHostKeyChecking=no $remote_user@$remote_host << EOF
echo "[ * ] Connecting to Remote Server:"
uptime
echo "IP address: $(hostname -I)"
echo "Country: $(geoiplookup $(hostname -I) | awk -F ": " '{print $2}')"

echo "[ * ] Whoising victim's address:"
whois $scan_target > whois_$scan_target.txt

echo "[ * ] Scanning victim's address:"
nmap $scan_target > nmap_$scan_target.txt
EOF

# Copy the results back to the local machine
scp $remote_user@$remote_host:~/whois_$scan_target.txt ~/Desktop/nipe/whois_$scan_target.txt
scp $remote_user@$remote_host:~/nmap_$scan_target.txt ~/Desktop/nipe/nmap_$scan_target.txt

# Save the Whois and Nmap data into files
echo "[ 3 ] Whois data was saved into /home/kali/Desktop/nipe/whois_$scan_target.txt."
echo "[ * ] Nmap scan was saved into /home/kali/Desktop/nipe/nmap_$scan_target.txt."

# Create a log and audit your data collecting
log_file="/var/log/nr.log"
echo "$(date) - Whois data collected for: $scan_target" >> $log_file
echo "$(date) - Nmap data collected for: $scan_target" >> $log_file

```

## How to run?

```bash
chmod +x NR.sh
sudo ./NR.sh
```
Version 1.0
Make sure to replace placeholders with actual values (e.g., username, remote.server.ip, your_password) before running the script.
