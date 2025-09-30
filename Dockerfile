FROM redhat/ubi9:latest

# Install SSH server and generate host keys
RUN dnf -y update && dnf -y install openssh-server && \
    ssh-keygen -A && \
    # Ensure root login is permitted
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    # Enable public key authentication
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config && \
    # Create necessary directories
    mkdir -p /var/run/sshd /root/.ssh

# Copy your public key (file must be in the same directory as Dockerfile)
COPY ansible.pub /root/.ssh/authorized_keys

# Set correct permissions
RUN chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys && \
    chown -R root:root /root/.ssh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]


