# KapsuleKorp IaC (Ansible + Terraform)

Projet de déploiement d'une stack LEMP pour deux environnements (staging et production) avec Ansible. Un scaffold Terraform (bonus) permet de provisionner des VM VirtualBox et de générer automatiquement l'inventaire Ansible.

## Structure
- `ansible/ansible.cfg` : configuration Ansible locale.
- `ansible/inventory.ini` : inventaire statique de référence (staging / production).
- `ansible/group_vars/all/main.yml` : variables globales.
- `ansible/group_vars/all/vault.yml` : secrets à chiffrer avec Ansible Vault.
- `ansible/site.yml` : playbook principal.
- `ansible/roles/` : rôles `common`, `web`, `app`, `db`.

## Prérequis
- Ansible >= 2.9 et accès SSH par clé sur les hôtes Ubuntu 22.04.
- Python 3 présent sur les cibles.

## Utilisation (Ansible)
1. Cloner le dépôt puis se placer dans `ansible/`.
2. Adapter `inventory.ini` avec les IP/hostnames de vos VMs et l'utilisateur SSH (`ansible_user`).
3. Renseigner vos secrets dans `group_vars/all/vault.yml` puis chiffrer :
   ```bash
   cd ansible
   ansible-vault encrypt group_vars/all/vault.yml
   ```
4. Lancer le déploiement :
   ```bash
   ansible-playbook -i inventory.ini site.yml --ask-vault-pass
   ```

## Rôles Ansible
- `common` : mise à jour APT et paquets de base (curl, git, ufw, python3-pymysql).
- `web` : installation Nginx + PHP-FPM, création du vhost, page PHP d'info, services activés.
- `app` : dépôt d'un `config.php` utilisant les secrets DB.
- `db` : installation MySQL, création du root/password, DB applicative et utilisateur, écoute réseau.

Variables clés (dans `group_vars/all/main.yml`) :
- `php_version`, `web_root`, `server_name`, `mysql_app_db`, `mysql_app_user`, `mysql_root_password` (secret), `mysql_app_password` (secret).

