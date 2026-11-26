
data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "app_lt" {

  name_prefix   = "app-server-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.app_ec2_sg.id
  ]


  user_data = base64encode(<<-EOF
#!/bin/bash

dnf install -y python3 python3-pip

mkdir -p /opt/app

python3 -m venv /opt/app/venv

/opt/app/venv/bin/pip install mysql-connector-python

cat > /opt/app/server.py <<'PY'
import os
from http.server import BaseHTTPRequestHandler, HTTPServer
import mysql.connector

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):

        if self.path == "/health":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Healthy")
            return

        if self.path == "/db":
            try:
                connection = mysql.connector.connect(
                    host=os.environ["DB_HOST"],
                    user=os.environ["DB_USER"],
                    password=os.environ["DB_PASSWORD"],
                    database=os.environ["DB_NAME"],
                    port=3306,
                    connection_timeout=5
                )

                cursor = connection.cursor()
                cursor.execute("SELECT 1")
                result = cursor.fetchone()

                cursor.close()
                connection.close()

                self.send_response(200)
                self.end_headers()
                self.wfile.write(
                    f"RDS MySQL Connected: {result}".encode()
                )

            except Exception:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b"Database connection failed")

        else:
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Hello from Application Tier")

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PY

cat > /etc/systemd/system/app.service <<'SERVICE'
[Unit]
Description=Three Tier Application
After=network.target

[Service]
Environment="DB_HOST=${aws_db_instance.main.address}"
Environment="DB_USER=${var.db_username}"
Environment="DB_PASSWORD=${var.db_password}"
Environment="DB_NAME=applicationdb"
ExecStart=/opt/app/venv/bin/python /opt/app/server.py
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

chmod 600 /etc/systemd/system/app.service

systemctl daemon-reload
systemctl enable --now app.service

EOF
  )


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Application-EC2"
      Tier = "Application"
    }
  }

}

resource "aws_launch_template" "web_lt" {

  name_prefix   = "web-server-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.web_ec2_sg.id
  ]


  user_data = base64encode(<<-EOF
#!/bin/bash
set -euxo pipefail

dnf install -y nginx

mkdir -p /usr/share/nginx/html

# Remove default Nginx page and old files
rm -f /usr/share/nginx/html/index.html
rm -f /usr/share/nginx/html/style.css

# Create custom HTML
cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>My Three Tier Application</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Welcome to My AWS Application</h1>
        <p>Three-Tier Architecture using AWS</p>
    </header>

    <div class="container">
        <h2>Application Deployed Successfully!</h2>
        <p>Web Tier | Application Tier | Database Tier</p>
        <button onclick="alert('Welcome!')">Get Started</button>
    </div>

    <footer>
        <p>Hosted on AWS using Terraform</p>
    </footer>
</body>
</html>
HTML

# Create CSS
cat > /usr/share/nginx/html/style.css <<'CSS'
body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f4f6f9;
    text-align: center;
}

header {
    background: #173b67;
    color: white;
    padding: 40px;
}

.container {
    background: white;
    margin: 60px auto;
    padding: 40px;
    width: 60%;
    border-radius: 10px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

button {
    background: #173b67;
    color: white;
    padding: 12px 25px;
    border: none;
    border-radius: 5px;
    cursor: pointer;
}

footer {
    background: #173b67;
    color: white;
    padding: 15px;
}
CSS

# Configure Nginx
rm -f /etc/nginx/conf.d/default.conf
rm -f /etc/nginx/conf.d/three-tier.conf

cat > /etc/nginx/conf.d/default.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location /api/ {
        proxy_pass http://${aws_lb.internal_alb.dns_name}/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINX

nginx -t
systemctl enable nginx
systemctl restart nginx

EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web-EC2"
      Tier = "Web"
    }
  }
}



  