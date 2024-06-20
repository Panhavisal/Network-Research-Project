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
