#!/bin/bash

# Append the entries to /etc/hosts
echo "192.168.56.110 app1.com" | sudo tee -a /etc/hosts > /dev/null
echo "192.168.56.110 app2.com" | sudo tee -a /etc/hosts > /dev/null

echo "Hosts file updated successfully."