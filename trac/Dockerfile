FROM maximatt/httpd-front:1.0

ENV container docker
WORKDIR /home/trac

ADD ./config/trac.wsgi /home/trac/trac.wsgi
ADD ./config/trac.conf /etc/httpd/conf.d/trac.conf
ADD ./config/tracEntrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 755 /usr/local/bin/entrypoint.sh; \
    yum -y install mod_wsgi trac python2-pip htmldoc subversion; \
    pip install --upgrade pip; \
    pip install -U xhtml2pdf==0.2b1; \
    pip install Pygments textile pillow TracXMLRPC svn+https://trac-hacks.org/svn/tracwysiwygplugin/0.12; \
    yum clean all;

EXPOSE 5002

VOLUME [ "/sys/fs/cgroup" ]

CMD /usr/local/bin/entrypoint.sh
