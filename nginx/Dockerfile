FROM nginx


COPY index2.html /usr/share/nginx/html/index2.html
COPY auto-reload-nginx.sh /home/auto-reload-nginx.sh
RUN chmod +r /usr/share/nginx/html/index2.html && \
    chmod +x /home/auto-reload-nginx.sh

# install inotify
RUN apt-get update && apt-get install -y inotify-tools
