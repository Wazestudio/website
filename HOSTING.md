# Héberger le site et l'installeur

Ce dépôt est volontairement **séparé** de celui du panel
([VPSControl/vps-control](https://github.com/VPSControl/vps-control)) : c'est
un simple site statique, il n'a pas besoin de Go ni de build step, et il n'a
aucune raison de vivre sur le même VPS que les serveurs de vos utilisateurs.

Il contient deux choses distinctes à héberger séparément :

- la racine du dépôt → le site vitrine + documentation, à servir sur **vpscontrol.wazestudio.com**
- `installer/get.sh` → le script à servir en texte brut sur **install.vpscontrol.wazestudio.com**

Les deux peuvent tourner sur le même petit serveur, via Nginx + Certbot pour
le HTTPS automatique.

## 1. Site vitrine — vpscontrol.wazestudio.com

Pointez un enregistrement DNS **A** de `vpscontrol.wazestudio.com` vers l'IP
du serveur qui hébergera le site, puis :

```bash
apt install -y nginx certbot python3-certbot-nginx
mkdir -p /var/www/vpscontrol-site
cp -r * /var/www/vpscontrol-site/    # depuis la racine de ce dépôt

cat >/etc/nginx/sites-available/vpscontrol-site.conf <<'EOF'
server {
    listen 80;
    server_name vpscontrol.wazestudio.com;
    root /var/www/vpscontrol-site;
    index index.html;
    location / { try_files $uri $uri/ =404; }
}
EOF
ln -sf /etc/nginx/sites-available/vpscontrol-site.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
certbot --nginx -d vpscontrol.wazestudio.com
```

C'est un site 100 % statique (HTML/CSS/JS vanilla, sans build step) : le
mettre à jour, c'est juste recopier ce dépôt par-dessus `/var/www/vpscontrol-site`.

## 2. Installeur curl — install.vpscontrol.wazestudio.com

Il doit répondre en texte brut avec le contenu de `installer/get.sh`, pour
que `curl -fsSL https://install.vpscontrol.wazestudio.com | sudo bash`
fonctionne.

Pointez un enregistrement DNS **A** de `install.vpscontrol.wazestudio.com`
vers l'IP du serveur, puis :

```bash
mkdir -p /var/www/vpscontrol-install
cp installer/get.sh /var/www/vpscontrol-install/index.html
# (le nommer index.html permet à Nginx de le servir directement à la racine)

cat >/etc/nginx/sites-available/vpscontrol-install.conf <<'EOF'
server {
    listen 80;
    server_name install.vpscontrol.wazestudio.com;
    root /var/www/vpscontrol-install;
    default_type text/plain;
    location / { try_files /index.html =404; }
}
EOF
ln -sf /etc/nginx/sites-available/vpscontrol-install.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
certbot --nginx -d install.vpscontrol.wazestudio.com
```

À chaque changement de `installer/get.sh`, recopiez-le par-dessus
`index.html` sur ce serveur.

## Avant de publier

`installer/get.sh` et les pages du site référencent
`https://github.com/VPSControl/vps-control` comme dépôt du panel — à adapter
si vous changez d'organisation ou de nom de dépôt sur GitHub. La variable à
changer dans `installer/get.sh` est `REPO_URL` en haut du fichier (ou à
passer via `VPSCONTROL_REPO_URL` au moment de l'exécution).
