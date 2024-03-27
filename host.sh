
local_ip=$(hostname -I)
echo "Local IP address: $local_ip"
python3 -m http.server 8080