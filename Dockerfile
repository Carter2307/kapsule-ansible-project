FROM ubuntu:22.04

# 1. Installer les paquets nécessaires
RUN apt update && apt install -y openssh-server python3 sudo

# 2. Créer l’utilisateur ubuntu
RUN useradd -m -s /bin/bash ubuntu

# 3. Préparer SSH
RUN mkdir -p /var/run/sshd
RUN mkdir -p /home/ubuntu/.ssh
RUN chmod 700 /home/ubuntu/.ssh

# 4. Recevoir et ajouter la clé publique selon l’environnement
ARG SSH_PUB_KEY
RUN echo "$SSH_PUB_KEY" > /home/ubuntu/.ssh/authorized_keys
RUN chmod 600 /home/ubuntu/.ssh/authorized_keys
RUN chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# 5. Activer sudo sans mot de passe (optionnel mais pratique)
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH port
EXPOSE 22

# Démarrer SSH
CMD ["/usr/sbin/sshd", "-D"]
