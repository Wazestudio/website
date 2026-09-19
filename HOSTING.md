# Héberger le site et l'installeur

Ce dépôt contient deux choses distinctes à héberger séparément :

- `website/` → le site vitrine + documentation, à servir sur **vpscontrol.lordobitotech.xyz**
- `installer/get.sh` → le script à servir en texte brut sur **install.vpscontrol.lordobitotech.xyz**

Les deux peuvent tourner sur n'importe quel petit VPS (ou même le même VPS
que celui qui héberge des projets de test), via Caddy pour le HTTPS
automatique.

## 1. Site vitrine — vpscontrol.lordobitotech.xyz

Pointez un enregistrement DNS **A** de `vpscontrol.lordobitotech.xyz` vers
l'IP du serveur qui hébergera le site, puis :

```bash
apt install -y caddy
mkdir -p /var/www/vpscontrol-site
cp -r website/* /var/www/vpscontrol-site/

cat >>/etc/caddy/Caddyfile <<'EOF'
vpscontrol.lordobitotech.xyz {
    root * /var/www/vpscontrol-site
    file_server
}
EOF
systemctl restart caddy
```

C'est un site 100% statique (HTML/CSS/JS vanilla, sans build step) : le
mettre à jour, c'est juste recopier `website/` par-dessus.

## 2. Installeur curl — install.vpscontrol.lordobitotech.xyz

Il doit répondre en texte brut au script `installer/get.sh`, pour que
`curl -fsSL https://install.vpscontrol.lordobitotech.xyz | sudo bash`
fonctionne.

Pointez un enregistrement DNS **A** de `install.vpscontrol.lordobitotech.xyz`
vers l'IP du serveur, puis :

```bash
mkdir -p /var/www/vpscontrol-install
cp installer/get.sh /var/www/vpscontrol-install/index.html
# (le nommer index.html permet à Caddy de le servir directement à la racine)

cat >>/etc/caddy/Caddyfile <<'EOF'
install.vpscontrol.lordobitotech.xyz {
    root * /var/www/vpscontrol-install
    header Content-Type "text/plain; charset=utf-8"
    file_server
}
EOF
systemctl restart caddy
```

À chaque changement de `installer/get.sh`, recopiez-le par-dessus
`index.html` sur ce serveur.

## Avant de publier

`installer/get.sh` et `website/index.html` référencent
`https://github.com/lordobitotech/vps-control` comme URL du dépôt — à adapter
si vous choisissez un autre nom d'organisation/dépôt sur GitHub. La variable
à changer dans `installer/get.sh` est `REPO_URL` en haut du fichier (ou en
la passant via `VPSCONTROL_REPO_URL` au moment de l'exécution).
