#!/bin/bash
set +e

LOG_FILE="./codespaces_setup.log"
echo "=== Codespaces Package Installation Log: $(date) ===" > "$LOG_FILE"

PACKAGES=(
    build-essential curl wget git unzip zip software-properties-common
    python3 python3-pip nodejs npm vim nano tmux htop jq net-tools
    dnsutils iputils-ping tree sqlite3 libsqlite3-dev zsh openssh-client
    ca-certificates gnupg lsb-release procps locales gettext cmake pkg-config
    autoconf automake libtool bison flex gdb valgrind strace ltrace
    linux-tools-common netcat-openbsd nmap tcpdump iperf3 traceroute whois
    telnet socat rsync screen byobu less man-db file bc cron logrotate
    lsof pciutils usbutils sysstat iftop iotop ncdu duf ripgrep fd-find
    fzf direnv shellcheck shfmt golang rustc cargo default-jdk ruby php
    perl lua5.4 postgresql-client mysql-client redis-tools libpq-dev libssl-dev
    libffi-dev zlib1g-dev libbz2-dev libreadline-dev libncurses5-dev libxml2-dev
    libxmlsec1-dev libxslt1-dev libyaml-dev libicu-dev libgdbm-dev libnss3-dev
    libasound2-dev libxtst-dev libx11-dev libxrandr-dev libxi-dev libxcursor-dev
    libxinerama-dev libgl1-mesa-dev libglu1-mesa-dev libfreetype6-dev
    libfontconfig1-dev libpng-dev libjpeg-dev libwebp-dev libtiff-dev
    imagemagick ffmpeg pandoc graphviz poppler-utils ghostscript texlive lynx
    w3m tig git-lfs subversion mercurial tar bzip2 gzip p7zip-full rar unrar
    zenity dialog whiptail acl attr ed patch diffutils time libpam0g-dev
    libcap-dev libudev-dev libblkid-dev libmount-dev libselinux1-dev libaudit-dev
    libacl1-dev libattr1-dev liblzma-dev liblz4-dev libzstd-dev libsnappy-dev
    libev-dev libevent-dev libuv1-dev libjemalloc-dev libtcmalloc-minimal4
    libapr1-dev libaprutil1-dev libnghttp2-dev libidn2-dev libpsl-dev libssh-dev
    libgcrypt20-dev libgpg-error-dev python3-venv python3-dev python3-setuptools
    python3-wheel python3-click python3-requests python3-yaml python3-jinja2
    python3-bs4 cloc entr parallel tor proxychains4 hexedit bleachbit ccache
    ninja-build swig doxygen graphviz-dev libgtest-dev libbenchmark-dev
)

echo "[*] Updating package list (apt-get update)..." | tee -a "$LOG_FILE"
sudo apt-get update >> "$LOG_FILE" 2>&1

echo "[*] Installing packages in bulk (this will be much faster)..." | tee -a "$LOG_FILE"

if sudo apt-get install -y "${PACKAGES[@]}" >> "$LOG_FILE" 2>&1; then
    echo "[SUCCESS] All packages installed successfully." | tee -a "$LOG_FILE"
else
    echo "[WARNING] Some packages failed to install. Check $LOG_FILE for details." | tee -a "$LOG_FILE"
fi

echo "=== Installation Completed: $(date) ===" | tee -a "$LOG_FILE"
echo "Logs have been saved to $LOG_FILE."
