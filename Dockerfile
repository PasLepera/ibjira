FROM paslepera/iborajre8:0.1
LABEL maintainer="Pasquale Lepera <pasquale@ibuildings.it>"

ENV JIRA_VERSION 7.9.0
ENV JIRA_HOME     	/var/atlassian/application-data/jira
ENV JIRA_INSTALL  	/opt/atlassian/jira
ENV JIRA_USER	  	jira
ENV JIRA_INSTALLER	atlassian-jira-software-$JIRA_VERSION-x64.bin

COPY ./installresp /tmp/installresp
COPY ./entrypoint.sh /entrypoint.sh

RUN deps=" \
	libtcnative-1 xmlstarlet \
	curl \
	wget \
	ca-certificates \
	openssl \
        " \
	set -x && \
    export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get upgrade -y $deps --no-install-recommends && \
	cd /tmp && \
        wget --no-check-certificate https://product-downloads.atlassian.com/software/jira/downloads/$JIRA_INSTALLER && \
        chmod a+x $JIRA_INSTALLER && \
        ./$JIRA_INSTALLER < /tmp/installresp && \ 
        mkdir -p $JIRA_HOME && \
	chown -R $JIRA_USER:$JIRA_USER $JIRA_HOME && \
	chown -R $JIRA_USER:$JIRA_USER $JIRA_INSTALL && \
        chown -R $JIRA_USER:$JIRA_USER /entrypoint.sh && \
	chmod +x /entrypoint.sh && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["${JIRA_HOME}"]

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
