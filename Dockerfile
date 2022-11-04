FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install sudo
RUN sudo apt-get update
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone
RUN apt-get install wget -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN apt-get install unzip -y
RUN sudo apt install python3 -y
RUN sudo apt install python3-dev -y
RUN sudo apt install python3-pip -y
RUN sudo apt install python3-pillow -y
RUN sudo apt update



RUN apt install tzdata -y
RUN apt install ffmpeg -y
RUN apt-get install nginx -y

COPY root /

RUN sudo chmod 777 /install.sh
RUN bash install.sh

RUN mv /nginx.conf /etc/nginx/


RUN pip3 install --upgrade pip

RUN sudo apt-get install gcc libffi-dev libssl-dev  -y
RUN mkdir /root/test
COPY config /root/test
RUN pip3 install -U pyrogram tgcrypto
#RUN pip3 install pillow
RUN pip3 install telegraph
RUN pip3 install mutagen
RUN pip3 install requests
RUN pip3 install apscheduler
RUN pip3 install pyromod
RUN pip3 install psutil
RUN pip3 install nest_asyncio
#RUN pip3 install pyppeteer
RUN pip3 uninstall websockets -y
RUN pip3 install websockets==6.0
RUN pip3 install pyppeteer
RUN sudo apt-get install  gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils -y
#RUN pyppeteer-install

RUN pip3 install nhentai --upgrade
RUN pip3 install beautifulsoup4 --upgrade
RUN apt-get install libxml2-dev libxslt-dev -y
RUN pip3 install lxml --upgrade

RUN mkdir /index
COPY /index.html /index

RUN mkdir /bot
COPY bot /bot
RUN chmod 0777 /bot/ -R


COPY /config/upload.sh /
RUN chmod 0777 /upload.sh

COPY /config/upload.sh /
RUN chmod 0777 /upload.sh

COPY /start.sh /
CMD chmod 0777 start.sh && bash start.sh
CMD wget https://raw.githubusercontent.com/winkxx/bot-arpt/main/start.sh -O start.sh && chmod 0777 start.sh && bash start.sh
