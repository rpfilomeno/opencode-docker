FROM ubuntu:26.04

# Set common environment variables
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Password for ssh
ENV USER_PASSWORD=123456

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install
RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y openssh-server \
    # Utils
    && apt-get install -y mc htop iotop ncdu tar zip nano vim bash sudo sed fzf wget ca-certificates curl unzip gnupg fzf tmux build-essential git ninja-build gettext cmake lazygit fd-find ripgrep tree-sitter-cli neovim gh age \
    # Net utils
    && apt-get install -y iputils-ping traceroute telnet dnsutils iperf nmap \
    # Deleting keys
    && rm -rf /etc/ssh/ssh_host_dsa* /etc/ssh/ssh_host_ecdsa* /etc/ssh/ssh_host_ed25519* /etc/ssh/ssh_host_rsa* \
    # Config SSH
    && sed -ri "s|^#PermitRootLogin|PermitRootLogin|" /etc/ssh/sshd_config \
    && sed -i "s|PermitRootLogin without-password|PermitRootLogin yes|" /etc/ssh/sshd_config \
    && sed -i "s|PermitRootLogin prohibit-password|PermitRootLogin yes|" /etc/ssh/sshd_config \
    && sed -ri "s|^#?PermitRootLogin\s+.*|PermitRootLogin yes|" /etc/ssh/sshd_config \
    && sed -ri "s|^#PasswordAuthentication|PasswordAuthentication|" /etc/ssh/sshd_config \
    && sed -ri "s|^PasswordAuthentication no|PasswordAuthentication yes|" /etc/ssh/sshd_config \
    && sed -ri "s|UsePAM yes|#UsePAM yes|g" /etc/ssh/sshd_config \
    # Cleaning
    && apt-get clean autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -rf /var/lib/apt/lists/*.lz4 \
    && rm -rf /var/log/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /usr/share/doc/ \
    && rm -rf /usr/share/man/ \
    && rm -rf $HOME/.cache


# Install Superfile
RUN bash -c "$(curl -sLo- https://superfile.dev/install.sh)"

# Install Starship with yes
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Install UV
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

RUN curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

#Install Zoxide
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s - --bin-dir /usr/local/bin/


# Create a non-root user
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

#RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo ubuntu
RUN echo 'ubuntu:ubuntu' | chpasswd

COPY scripts /home/ubuntu
RUN chown -R ubuntu:ubuntu /home/ubuntu


USER ubuntu
WORKDIR /home/ubuntu
RUN source .bashrc

# Prepare SSH configuration
RUN mkdir -p /home/ubuntu/.ssh \
    && touch /home/ubuntu/.ssh/known_hosts

# Preload GitHub host keys (non-interactive Git usage)
RUN ssh-keyscan -T 5 github.com 2>/dev/null >> /home/ubuntu/.ssh/known_hosts || true

RUN git clone https://github.com/LazyVim/starter /home/ubuntu/.config/nvim \
    && rm -rf /home/ubuntu/.config/nvim/.git

RUN mise use -g node
RUN mise use -g go 
RUN mise use -g python
RUN mise use -g rust
RUN mise use -g opencode


USER root
COPY skill /home/ubuntu/.config/opencode/skill
RUN chown -R ubuntu:ubuntu /home/ubuntu/.config/opencode/skill
RUN mkdir -p /workspace
RUN chown -R ubuntu:ubuntu /workspace


COPY deploy /
RUN chmod +x /entrypoint.sh

EXPOSE 22/tcp
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]