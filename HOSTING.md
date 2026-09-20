# Hosting the site and the installer

This repo is deliberately **separate** from the panel's own repo
([Wazestudio/vps-control](https://github.com/Wazestudio/vps-control)): it's
a plain static site, it doesn't need Go or a build step, and it has no
reason to live on the same VPS as your users' servers.

It holds two distinct things to host separately:

- the root of the repo → the marketing site + docs, served on **vpscontrol.wazestudio.com**
- `installer/get.sh` → the script served as plain text on **install.vpscontrol.wazestudio.com**

Both can run on the same small server, using Nginx + Certbot for automatic HTTPS.

## 1. Marketing site — vpscontrol.wazestudio.com

Point an **A** DNS record for `vpscontrol.wazestudio.com` at the IP of the
server that will host the site, then:

```bash
apt install -y nginx certbot python3-certbot-nginx
mkdir -p /var/www/vpscontrol-site
cp -r * /var/www/vpscontrol-site/    # from the root of this repo

cat >/etc/nginx/sites-available/vpscontrol-site.conf <<'NGINX_SITE_CONF'
server {
    listen 80;
    server_name vpscontrol.wazestudio.com;
    root /var/www/vpscontrol-site;
    index index.html;
    location / { try_files $uri $uri/ =404; }
}
NGINX_SITE_CONF
ln -sf /etc/nginx/sites-available/vpscontrol-site.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
certbot --nginx -d vpscontrol.wazestudio.com
```

It's a 100% static site (vanilla HTML/CSS/JS, no build step): updating it is
just copying this repo over `/var/www/vpscontrol-site` again.

## 2. Curl installer — install.vpscontrol.wazestudio.com

It needs to respond with the plain-text content of `installer/get.sh`, so
that `curl -fsSL https://install.vpscontrol.wazestudio.com | sudo bash`
works.

Point an **A** DNS record for `install.vpscontrol.wazestudio.com` at the
server's IP, then:

```bash
mkdir -p /var/www/vpscontrol-install
cp installer/get.sh /var/www/vpscontrol-install/index.html
# (naming it index.html lets Nginx serve it directly at the root)

cat >/etc/nginx/sites-available/vpscontrol-install.conf <<'NGINX_INSTALL_CONF'
server {
    listen 80;
    server_name install.vpscontrol.wazestudio.com;
    root /var/www/vpscontrol-install;
    default_type text/plain;
    location / { try_files /index.html =404; }
}
NGINX_INSTALL_CONF
ln -sf /etc/nginx/sites-available/vpscontrol-install.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
certbot --nginx -d install.vpscontrol.wazestudio.com
```

Every time `installer/get.sh` changes, copy it over `index.html` on this
server again.

## Before you publish

`installer/get.sh` and the site pages reference
`https://github.com/Wazestudio/vps-control` as the panel's repo — update
this if you use a different org or repo name on GitHub. The variable to
change in `installer/get.sh` is `REPO_URL` near the top of the file (or pass
it via `VPSCONTROL_REPO_URL` at runtime).
