FROM debian-python-gradio:latest as base

# User SSH key
WORKDIR /root
RUN apt-get update && \
    apt-get install openssh-client -yq && \
    apt-get clean
RUN ssh-keygen -A && \
    ssh-keygen -t rsa -f id_rsa -P "" && \
    cat id_rsa.pub && echo ""

# Update the runtime image
FROM debian-python-gradio:latest

# SSH keys and config
WORKDIR /root
RUN apt-get update && \
    apt-get install openssh-server -yq && \
    apt-get clean
COPY --from=base /root/id_rsa.pub .
RUN mkdir -p /run/sshd && \
    mkdir -p .ssh && \
    mv id_rsa.pub .ssh/authorized_keys && \
    echo "root:Docker!" | chpasswd
COPY sshd_config /etc/ssh/

# User Shell
RUN sed -i '/root/s/ash/bash/g' /etc/passwd

# Export
ENV PORT 8080
EXPOSE 8080
EXPOSE 2222
WORKDIR /app
ENTRYPOINT /usr/sbin/sshd && /scripts/start.sh
