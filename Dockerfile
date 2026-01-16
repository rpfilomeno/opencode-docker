FROM ubuntu:24.04

# Set common environment variables
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Password for ssh
ENV USER_PASSWORD=123456

# Copy to image
COPY deploy /

# Install
RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y openssh-server \
    # Utils
    && apt-get install -y mc htop iotop ncdu tar zip nano vim bash sudo sed fzf wget ca-certificates curl unzip gnupg fzf tmux build-essential git ninja-build gettext cmake lazygit fd-find ripgrep tree-sitter-cli\
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
    && rm -rf $HOME/.cache \
    && chmod +x /entrypoint.sh


# Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    # Clean up APT lists
    && rm -rf /var/lib/apt/lists/*



SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"
RUN mkdir /mise
RUN curl https://mise.run | sh
RUN mise use -g node
RUN mise use -g go 
RUN mise use -g python
RUN mise use -g rust

#Istall age
RUN go install filippo.io/age/cmd/...@latest

#Install Zoxide
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Install Superfile
RUN bash -c "$(curl -sLo- https://superfile.dev/install.sh)"

# Install Starship with yes
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Install UV
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Lazyvim

RUN curl -LO --create-dirs --output-dir /opt/nvim https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage \
    && chmod u+x nvim-linux-x86_64.appimage \
    && ./nvim-linux-x86_64.appimage

# Create a non-root user
RUN echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
WORKDIR /home/ubuntu

# Prepare SSH configuration
RUN mkdir -p /home/ubuntu/.ssh \
    && touch /home/ubuntu/.ssh/known_hosts

# Preload GitHub host keys (non-interactive Git usage)
RUN ssh-keyscan -T 5 github.com 2>/dev/null >> /home/ubuntu/.ssh/known_hosts || true

RUN mkdir -p /home/ubuntu/.config \
    && git clone https://github.com/LazyVim/starter /home/ubuntu/.config/nvim \
    && rm -rf /home/ubuntu/.config/nvim/.git


# Install OpenCode AI (Native Binary Method)
# https://opencode.ai/docs/
RUN curl -fsSL https://opencode.ai/install | bash

RUN npm install -g @google/gemini-cli

EXPOSE 22/tcp

USER root

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]