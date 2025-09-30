# Create Key-Pair

1. Generate SSH key pair:
   ```bash
   ssh-keygen -t ed25519 -C "ansible"
   ```
   - Enter path: `/home/${USER}/.ssh/ansible`
   - You'll see `ansible` (Private Key) and `ansible.pub` (Public Key)

# Goal: Create 3 Servers and Configure with Ansible

## Strategy to Create 3 Servers:

### 1) Download Docker Image
```
redhat/ubi9    latest    a169546264dd    12 days ago    210MB
```
- This is the free version of RHEL which doesn't require authentication to download

### 2) Create Custom Image with SSH Public Certificate
1. Go to project directory
2. Build the image:
   ```bash
   docker build -t rhel-server:v1.0 .
   ```
3. Run 3 containers mapping port 22 to different host ports:
   ```bash
   docker run -d -p 2222:22 --name rhel-server-1 rhel-server:v1.0
   docker run -d -p 2223:22 --name rhel-server-2 rhel-server:v1.0
   docker run -d -p 2224:22 --name rhel-server-3 rhel-server:v1.0
   ```
4. Check running containers:
   ```bash
   docker ps
   ```

### 3) SSH into the Machines
- Use your private key to connect to each server:
    ```bash
    ssh -i ~/.ssh/ansible root@172.17.0.1 -p 2222
    ssh -i ~/.ssh/ansible root@172.17.0.1 -p 2223
    ssh -i ~/.ssh/ansible root@172.17.0.1 -p 2224
    ```

# Install Ansible
If Ansible is not installed, install it with:
```bash
sudo apt install ansible  # For Ubuntu
```

# Configure Ansible

## Inventory File
The inventory file contains server_name, IP address, and port.

Run this command to ping the servers:
```bash
ansible all -i inventory -m ping -u root --private-key ~/.ssh/ansible
```
- `-m` = module (the ping module is run)
- You'll receive a pong from the Python interpreter, meaning that it works

## Set up Config File
Set up the config file `ansible.cfg`, then just run:
```bash
ansible all -m ping
```

## Additional Commands
```bash
ansible all --list-hosts
ansible all -m gather_facts
ansible all -m gather_facts --limit hostname  # This is for checking values and cross-verifying with playbook to debug issues 
```

## Package Management
```bash
ansible all -m dnf -a "update_cache=true"
ansible all -m dnf -a "update_cache=true" --become --ask-become-pass 

# Install Package
ansible all -m dnf -a "name=docker"
ansible all -m shell -a "dnf search podman"
```

## Log Files
In the server you can go to this path:
```
/var/log/
```
`dnf.log` contains history of commands run. You can tail it and see the log entries.