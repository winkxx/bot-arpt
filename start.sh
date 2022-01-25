#!/bin/bash
#!！




touch /root/.aria2/aria2.session
chmod 0777 /root/.aria2/ -R

nohup filebrowser -r /  -p 9184 >> /dev/null 2>&1 & 
#nohup ./FolderMagic -aria "http://127.0.0.1:8080/jsonrpc" -auth root:$Aria2_secret -bind :9184 -root / -wd /webdav >> /dev/null 2>&1 & 

mkdir /.config/
mkdir /.config/rclone
mkdir /root/.config/rclone
touch /.config/rclone/rclone.conf
mkdir /root/.config/
mkdir /root/.config/rclone
touch /root/.config/rclone/rclone.conf
echo "$conf" >>/.config/rclone/rclone.conf
echo "$conf" >>/root/.config/rclone/rclone.conf

wget git.io/tracker.sh
chmod 0777 /tracker.sh
/bin/bash tracker.sh "/root/.aria2/aria2.conf"

rm -rf /bot
git clone https://github.com/winkxx/bot-arpt.git
chmod 0777 /bot-arpt
mkdir /bot/
chmod 0777 /bot
mv /bot-arpt/bot/* /bot/

rm /etc/nginx/nginx.conf
cp /bot-arpt/root/nginx.conf /etc/nginx/

rm -rf /bot-arpt

#python3 /bot/nginx.py
nginx -c /etc/nginx/nginx.conf
nginx -s reload

nohup aria2c --conf-path=/root/.aria2/aria2.conf --rpc-listen-port=8080 --rpc-secret=$Aria2_secret &
nohup rclone rcd --rc-addr=127.0.0.1:5572 --rc-user=root --rc-pass=$Aria2_secret --rc-allow-origin="https://elonh.github.io" &
#nohup python3 /bot/web.py &

python3 /bot/main.py
