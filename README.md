# KapsuleKorp IaC — Dossier projet (Ansible + labo Docker)

Documentation destinée au rendu : déploiement d'une stack LEMP (Nginx, PHP-FPM, MySQL) sur deux environnements (staging, production) via Ansible. Un labo Docker Compose fournit les hôtes Ubuntu 22.04 accessibles en SSH pour rejouer les playbooks sans dépendre d'un cloud.

## Objectifs du projet
- Illustrer une chaîne IaC simple : provisionnement réseau simulé + configuration serveurs avec Ansible.
- Séparer clairement les environnements (groupes `staging_*` et `prod_*`).
- Industrialiser la stack via des rôles (`common`, `web`, `app`, `db`) et un inventaire versionné.

## Architecture et structure
- `ansible/` : `site.yml`, `inventory.ini`, config `ansible.cfg`, `group_vars/`, rôles `common`, `web`, `app`, `db`.
- `docker-compose.yml` + `Dockerfile` : 7 conteneurs Ubuntu avec IP fixes (192.168.56.0/24) et clé publique injectée pour SSH.
- `ssh-keys/` : clés privées/publiques pour accéder aux conteneurs (`staging`, `prod`).
- `.env` : variables pour Docker Compose (`STAGING_KEY`, `PROD_KEY`, `VAULT_PASS`).

## Prérequis
- Docker + Docker Compose.
- Ansible ≥ 2.9 installé en local (client SSH) + Python 3.
- Optionnel : `ansible-vault` pour chiffrer `group_vars/all/vault.yml`.

## Mise en route du labo Docker
1. Cloner le dépôt, se placer à la racine.
2. (Recommandé) Régénérer les clés :
   ```bash
   ssh-keygen -t ed25519 -f ssh-keys/staging -N ""
   ssh-keygen -t ed25519 -f ssh-keys/prod -N ""
   # Mettre à jour .env avec les nouvelles clés publiques
   ```
3. Vérifier `.env` (`STAGING_KEY`, `PROD_KEY`, `VAULT_PASS`).
4. Lancer les hôtes simulés :
   ```bash
   docker compose up -d --build
   docker compose ps  # vérifier les IP 192.168.56.x
   ```
   Les IP correspondent à `ansible/inventory.ini`.

## Préparer Ansible
- Ajuster l'inventaire si besoin : `ansible/inventory.ini` (IP, `ansible_user`, groupes).
- Renseigner les secrets dans `ansible/group_vars/all/vault.yml`, puis chiffrer :
  ```bash
  cd ansible
  ansible-vault encrypt group_vars/all/vault.yml  # mot de passe par défaut : kapsule
  cd ..
  ```
- Sécuriser les clés privées : `chmod 600 ssh-keys/staging ssh-keys/prod`.

## Lancer les playbooks
Depuis `ansible/` :
- Staging :
  ```bash
  ansible-playbook -i inventory.ini site.yml --limit staging \
    --private-key ../ssh-keys/staging --ask-vault-pass
  ```
- Production :
  ```bash
  ansible-playbook -i inventory.ini site.yml --limit prod \
    --private-key ../ssh-keys/prod --ask-vault-pass
  ```

## Ce qui est déployé
- `common` : mise à jour APT, paquets de base, ufw, dépendances Python.
- `web` : Nginx + PHP-FPM, vhost sur `{{ web_root }}`, page PHP d'info, services activés.
- `app` : `config.php` utilisant les secrets DB.
- `db` : MySQL, mots de passe root/app (Vault), base + utilisateur applicatif, écoute réseau activée.

## Vérifications rapides
- SSH : `ssh -i ssh-keys/staging ubuntu@192.168.56.11` (ou IP cible).
- Nginx/PHP : depuis un hôte web, `curl localhost` retourne la page PHP info.
- MySQL : `mysql -u root -p -h 127.0.0.1` sur l'hôte DB (mot de passe Vault).

## Arrêt / nettoyage
- Arrêter le labo : `docker compose down` (ajouter `-v` pour supprimer les volumes si nécessaire).
- Si vous régénérez les clés, mettre à jour `.env` puis relancer `docker compose up -d --build`.

## Notes pour le rendu
- Le dépôt contient tout le nécessaire pour rejouer l'infra en local (aucun cloud requis).
- Le mot de passe Vault par défaut (`kapsule`) est dans `.env` pour faciliter la correction.
