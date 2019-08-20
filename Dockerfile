FROM nginx
RUN apt-get update
RUN apt-get install net-tools -y
RUN apt-get install curl -y
RUN apt-get install jq -y
COPY default.conf /etc/nginx/conf.d/
COPY static-html-directory /usr/share/nginx/html
COPY run.sh /root/bin.sh
RUN chmod +x /root/bin.sh
ENTRYPOINT ["/root/bin.sh"]
