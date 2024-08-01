#!/bin/bash

log() {
    echo -e "\033[32m$@\033[0m"
}

log_err() {
    echo -e "\033[31m$@\033[0m"
    exit 1
}

spotify() {
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update -qq 2>&1
    sudo apt install -y spotify-client
}

google_chrome() {
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo gdebi $(pwd)/google-chrome-stable_current_amd64.deb
    rm $(pwd)/google-chrome-stable_current_amd64.deb
}

docker() {
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -qq 2>&1
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    newgrp docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
}

gammastep() {
	sudo apt install -y gammastep
	if [[ ! -d ~/.config/gammastep ]]; then
		mkdir -p ~/.config/gammastep
	fi

	if [[ ! -f ~/.config/gammastep ]]; then
		cat << EOF | tee ~/.config/gammastep/config.ini
[general]
temp-day=5800
temp-night=3200
gamma=0.9
adjustment-method=randr
location-provider=manual
[manual]
lat=-34.603722
lon=-58.381592
EOF
    fi
}

proton_vpn() {
    wget https://repo2.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb
    sudo gdebi $(pwd)/protonvpn-stable-release_1.0.3-3_all.deb
    sudo apt update -qq 2>&1
    sudo apt install -y proton-vpn-gnome-desktop
    rm $(pwd)/protonvpn-stable-release_1.0.3-3_all.deb
}

steam() {
    wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
    sudo gdebi $(pwd)/steam.deb
    rm $(pwd)/steam.deb
}

themes() {
    sudo apt install -y papirus-icon-theme bibata-cursor-theme
    sudo apt install -y fonts-hack fonts-recommended fonts-ubuntu fonts-liberation2 fonts-cantarell fonts-jetbrains-mono
    sudo git clone https://github.com/EliverLara/Sweet.git /usr/share/themes/Sweet
    cd /usr/share/themes/Sweet
    sudo git checkout nova
}

telegram() {
    wget https://telegram.org/dl/desktop/linux -O tsetup.tgz
    sudo mkdir -p /opt/Telegram
    sudo tar xf $(pwd)/tsetup.tgz -C /opt/Telegram --strip-components=1
    sudo ln -s /opt/Telegram/Telegram /usr/local/bin/telegram
    sudo ln -s /opt/Telegram/Updater /usr/local/bin/telegramUpdater
    rm $(pwd)/tsetup.tgz
}

megasync() {
	wget https://mega.nz/linux/repo/Debian_12/amd64/megasync-Debian_12_amd64.deb
	sudo gdebi $(pwd)/megasync-Debian_12_amd64.deb
    rm $(pwd)/megasync-Debian_12_amd64.deb
}

vscode() {
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update -qq 2>&1
    sudo apt install -y code
}

disable_wifi_powersave() {
    if [[ ! -f /etc/NetworkManager/conf.d/wifi-powersave-off.conf ]]; then
        cat << EOF | sudo tee /etc/NetworkManager/conf.d/wifi-powersave-off.conf
[connection]
wifi.powersave = 2 # 0=default 1=existing 2=disabled 3=enabled 
EOF
    	sudo systemctl restart NetworkManager 2>&1
    fi
}

create_alias_file() {
    if [[ ! -f ~/.bash_aliases ]]; then
    cat << EOF | tee ~/.bash_aliases
alias ll='ls -lrth --color=auto'
alias LL='ls -lArth --color=auto'
alias LA='ls -lARth --color=auto'
alias df='df -h'
alias top='htop'
EOF
    fi
}

repo_edit() {
	if [[ `grep contrib non-free /etc/apt/sources.list|wc -l` -eq 0 ]]; then
		sudo sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
	fi
	if [[ `grep backports /etc/apt/sources.list|wc -l` -eq 0 ]]; then
	sudo sed -i '$a\deb http://ftp.us.debian.org/debian/ bookworm-backports main contrib non-free non-free-firmware' /etc/apt/sources.list
	fi
	sudo apt update -qq 2>&1
}

xdg_move_dirs() {
	rm -r ~/Pictures
	rm -r ~/Public
	rm -r ~/Templates
	rm -r ~/Videos
	rm -r ~/Music
	rm -r ~/Desktop
	xdg-user-dirs-update
}

rename_background_files() {
    DIR=`ls "$1"`
    for file in ${DIR[@]}; do
    	newName=$(date +%s%N | sha256sum | base64 | head -c 12 | tr -d '+/=')."${file##*.}"
    	echo "file renamed: $file -> $newName"
    done
}

fprint_reader() {
    sudo wget 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2937db010da51096cd4277ff8d4c774ba6d18f90' -O /etc/apt/trusted.gpg.d/uunicorn.asc
    echo -e 'deb [signed-by=/etc/apt/trusted.gpg.d/uunicorn.asc] https://ppa.launchpadcontent.net/uunicorn/open-fprintd/ubuntu kinetic main\n#deb-src [signed-by=/etc/apt/trusted.gpg.d/uunicorn.asc] https://ppa.launchpadcontent.net/uunicorn/open-fprintd/ubuntu kinetic main' | sudo tee /etc/apt/sources.list.d/uunicorn-open-fprintd.list
    sudo apt update -qq 2>&1
    sudo apt install -y open-fprintd fprintd-clients python3-validity

    cat << EOF | sudo tee /etc/systemd/system/fingerprint-restart.service
[Unit]
Description=Restart services to fix fingerprint integration
After=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=systemctl restart open-fprintd.service python3-validity.service

[Install]
WantedBy=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable fingerprint-restart.service
    sudo pam-auth-update
}

show_menu() {
    local choice
    read -p "Enter choice: " choice
    case $choice in
        1) google_chrome;;
        2) spotify;;
        3) docker;;
		4) gammastep;;
		5) proton_vpn;;
		6) steam;;
		7) themes;;
		8) telegram;;
		9) megasync;;
		10) vscode;;
		11) fprint_reader;;
		99) exit 0;;
        *) echo_warning "Invalid option" && sleep 2
    esac
}


if [[ "$(lsb_release -si)" != "Debian" ]] || [[ "$(lsb_release -sr | cut -d. -f1)" != "12" ]]; then
	log_err "os distro or version missmatch"
fi

if [[ "$EUID" -eq 0 ]]; then
	log_err "run this script without sudo"
fi

while true; do
	show_menu    
done
