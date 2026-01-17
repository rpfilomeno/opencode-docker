# Opencode Docker

This project provides a secure, isolated Docker environment designed for running **Opencode** agents. It features a fully-featured development environment accessible remotely via **OpenSSH** over a secure **Tailscale** VPN mesh network.

![Opencode Docker Demo](https://cdn.rogverse.fyi/WindowsTerminal_1BCHwo8nFM.gif)


## 🚀 Features

*   **Secure Isolation**: Runs in a self-contained container based on Ubuntu.
*   **Remote Access**: Accessible securely from anywhere via Tailscale no ports opened on the public internet.
*   **Persistent Configuration**: Your workspace and configurations (Neovim, Opencode) are persisted across restarts.
*   **GPU Support**: Pre-configured for NVIDIA GPU acceleration.
*   **Rich Tooling**: Comes pre-loaded with a modern suite of CLI tools and development runtimes.

## 🛠️ Getting Started

### Prerequisites

*   [Docker](https://docs.docker.com/get-docker/) installed on your host machine.
*   A [Tailscale](https://tailscale.com/) account and an auth key.

### Installation & Usage

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd opencode-docker
    ```

2.  **Configure Environment Variables:**
    Create a `.env` file in the root directory (or set these variables in your shell) with your secrets:

    ```bash
    TAILSCALE_AUTHKEY=tskey-auth-xxxxx-xxxxxxxxx  # Your Tailscale Auth Key
    USER_PASSWORD=secretpassword                  # Password for the 'ubuntu' user
    ```

3.  **Start the Container:**
    Run the following command to bring up the environment:

    ```bash
    docker-compose up -d
    ```

4.  **Connect via SSH:**
    Once running, the machine will appear in your Tailscale network as `opencode`. You can SSH into it:

    ```bash
    ssh ubuntu@opencode
    ```
    *(Or use the Tailscale IP address directly if DNS is not configured)*

## 🧰 Included Tools

This environment is packed with tools to maximize productivity:

### Core & Shell
*   **Shell**: `bash` with `starship` prompt.
*   **Multiplexers**: `tmux`, `byobu`.
*   **Editors**: `neovim` (NVIM), `vim`, `nano`.
*   **File Managers**: `superfile`, `mc` (Midnight Commander).
*   **Navigation**: `zoxide` (smarter cd), `gum`.

### Development Runtimes (managed via `mise`)
*   **Node.js**
*   **Go**
*   **Python** (also with `uv`)
*   **Rust**
*   **Opencode CLI**

### Utilities
*   **Search**: `fzf`, `rg` (ripgrep), `fd` (fd-find).
*   **Git**: `git`, `lazygit`, `gh` (GitHub CLI).
*   **System**: `htop`, `iotop`, `ncdu`, `fastfetch`.
*   **Archives**: `tar`, `zip`, `unzip`.
*   **Network**: `curl`, `wget`, `nmap`, `iperf`, `dnsutils`, `ping`.
*   **Modern Replacements**: `bat` (cat clone), `exa` (ls clone).
*   **Security**: `age`, `gnupg`, `openssh-server`.
*   **Build**: `build-essential`, `cmake`, `ninja-build`.

## 📂 Volume Mappings

The following directories are mapped to the host to ensure data persistence:

*   `./workspace` -> `/home/ubuntu/workspace`: Main working directory.
*   `./config/opencode` -> `/home/ubuntu/.config/opencode`: Opencode configuration.
*   `./config/nvim` -> `/home/ubuntu/.config/nvim`: Neovim configuration.
