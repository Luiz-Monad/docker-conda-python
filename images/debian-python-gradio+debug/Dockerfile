FROM debian-python-gradio:latest as base

# User SSH key
WORKDIR /root
ENV DEBIAN_FRONTEND=noninteractive
ENV apt_args='-o=Dpkg::Use-Pty=0 -qq -y'
RUN apt-get update $apt_args && \
    apt-get install $apt_args openssh-client && \
    apt-get clean $apt_args
RUN ssh-keygen -A && \
    ssh-keygen -t rsa -f id_rsa -P "" && \
    cat id_rsa.pub && echo ""

# Update the runtime image
FROM debian-python-gradio:latest

# SSH keys and config
WORKDIR /root
ENV DEBIAN_FRONTEND=noninteractive
ENV apt_args='-o=Dpkg::Use-Pty=0 -qq -y'
RUN apt-get update $apt_args && \
    apt-get install $apt_args --no-install-recommends openssh-server && \
    apt-get clean $apt_args
COPY --from=base /root/id_rsa.pub .
RUN mkdir -p /run/sshd && \
    mkdir -p .ssh && \
    mv id_rsa.pub .ssh/authorized_keys
    # echo "root:Docker!" | chpasswd
COPY sshd_config /etc/ssh/

# User Shell
RUN sed -i '/root/s/ash/bash/g' /etc/passwd

# Export
ENV PORT 8080
EXPOSE 8080
EXPOSE 2222
WORKDIR /app
ENTRYPOINT /usr/sbin/sshd && /scripts/start.sh
