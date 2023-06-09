FROM amazonlinux:2023.0.20230517.1

#https://stackoverflow.com/a/72551258
ENV PIP_ROOT_USER_ACTION=ignore

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV PYTHONUNBUFFERED=1
ENV LANG=C.UTF-8
#https://stackoverflow.com/questions/59732335/is-there-any-disadvantage-in-using-pythondontwritebytecode-in-docker/60797635#60797635
ENV PYTHONDONTWRITEBYTECODE 1


RUN set -eux; \
    yum update -y
RUN set -eux; \
     yum -y groupinstall "Development Tools"

RUN set -eux; \
    yum -y install https://rpmfind.net/linux/fedora/linux/releases/38/Everything/x86_64/os/Packages/p/perl-Time-Duration-1.21-13.fc38.noarch.rpm \
            perl-IPC-Run \
            https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/m/moreutils-0.49-2.el7.x86_64.rpm && \
    yum -y install openssl-devel libffi-devel bzip2-devel  \
                  wget nano mlocate moreutils #sponge is in moreutils


RUN set -eux; \
    yum -y install python3

RUN set -eux; \
    mkdir -p /tmp && cd /tmp; curl -O https://bootstrap.pypa.io/get-pip.py; \
                            python3 get-pip.py; \
                            pip --version; \
                            rm get-pip.py;

RUN set -eux; \
    cd /usr/bin && ln -sf python3.9 python; \
    pip config set global.cache-dir false; \
    #https://superuser.com/a/1596517 \
    sed "s/eepcache=1/eepcache=0/" /etc/yum.conf | sponge /etc/yum.conf

RUN set -eux; \
    python3 -V



RUN set -eux; \
    cd /usr/bin && ln -sf python3.9 python; \
    pip config set global.cache-dir false; \
    #https://superuser.com/a/1596517 \
    sed "s/eepcache=1/eepcache=0/" /etc/yum.conf | sponge /etc/yum.conf;

#COPY requirements.txt /etc/requirements.txt



RUN set -ex && \
     #latest pip,setuptools,wheel
     pip install --upgrade pip==23.1.2 setuptools==67.8.0 wheel==0.36.1
     #pip install -r etc/requirements.txt


#Cleanup
RUN set -ex && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /var/cache/yum

RUN set -eux; \
    updatedb;

WORKDIR /

##CMD ["/bin/sh"]
CMD tail -f /dev/null



#docker system prune --all
#docker rm -f py39 py39a
#docker rmi -f py39i py39ai py39bi
#docker build --no-cache . -t py39i
##docker build . -t py39i
###docker build --squash . -t py39i
#docker run --name py39 -d py39i
#docker exec -it $(docker ps -q -n=1) bash
#smoke test
#docker exec -it $(docker ps -q -n=1) pip config list
#docker exec -it $(docker ps -q -n=1) bash

#docker export $(docker ps -q -n=1) | docker import - py39ai
#docker run --name py39a -d py39ai bash

#populate from docker inspect -f "{{ .Config.Env }}" py39
#populate from docker inspect -f "{{ .Config.Cmd }}" py39
#based on https://docs.docker.com/engine/reference/commandline/commit/
#docker commit --change "CMD /bin/sh" \
#              --change "ENV PATH=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
#                        PIP_ROOT_USER_ACTION=ignore \
#                        PYTHONUNBUFFERED=1 \
#                        LANG=C.UTF-8 \
#                        PYTHONDONTWRITEBYTECODE=1" \
#    $(docker ps -q -n=1) py39bi



#docker tag py39bi alexberkovich/al2023-python39
#docker push alexberkovich/al2023-python39:0.0.1
#docker push alexberkovich/al2023-python39:latesst


#EOF
