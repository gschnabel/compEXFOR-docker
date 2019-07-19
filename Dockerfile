FROM ubuntu:18.04
COPY install_all.sh /home
RUN chmod -R 744 /home/install_all.sh
RUN /home/install_all.sh; rm /home/install_all.sh
CMD /home/startup.sh
# mongodb server port
EXPOSE 27017
