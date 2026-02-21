#! /bin/bash
# --- STARTUP SCRIPT ---
# This script runs the first time an instance boots to configure the application.

set -euo pipefail

# 1. INSTALL DEPENDENCIES
# Nginx for the web server, and MySQL client to test connectivity.
apt update
apt -y install nginx-light wget default-mysql-client

# 2. INSTALL CLOUD SQL AUTH PROXY
# This tool allows secure, encrypted connection to Cloud SQL without opening public IPs.
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/bin/cloud_sql_proxy
chmod +x /usr/bin/cloud_sql_proxy

# 3. DYNAMIC METADATA & SECRET RETRIEVAL
# 'NAME' and 'IP' are fetched from the Google Metadata server.
NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name")
IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")

# SECRET FETCH: The instance uses its Service Account (sa_name) to 'ask' Secret Manager 
# for the database connection string. This is the "Secret Zero" security pattern.
CONNECTION_NAME=$(gcloud secrets versions access latest --secret="connection-name" --format='get(payload.data)' | tr '_-' '/+' | base64 -d)

# 4. GENERATE LANDING PAGE
# Create a simple HTML file to show the instance is healthy and provide connection instructions.
cat <<EOF > /var/www/html/index.html
<html>
   <body>
      <p>Hello World!</p>
      <p>The current version is: V1.0</>
      <p>My name is: $NAME</>
      <p>My internal IP is: $IP</p>
      <hr>
      <p><strong>Database Connection Lab:</strong></p>
      <p>Paste these two commands into your SSH session to connect to the database:</p>
      <pre>
<code>
# Step 1: Start the secure proxy tunnel in the background
cloud_sql_proxy -instances=$CONNECTION_NAME=tcp:3306 &

# Step 2: Connect via the local tunnel
mysql -u user --host 127.0.0.1 --port 3306 -p
</code>
</pre>
   </body>
</html>

