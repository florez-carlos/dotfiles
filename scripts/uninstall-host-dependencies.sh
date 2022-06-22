#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)


remove_docker() {
	
	
	printf "%s\n" ""
	printf "%s\n" " -> Beginning Docker removal: "
	printf "%s\n" ""
	sleep 1
	apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
	apt-get autoremove -y
	rm -rf /var/lib/docker
	rm -rf /var/lib/containerd
	rm /etc/apt/keyrings/docker.gpg
	groupdel docker
}

remove_fonts() {

	printf "%s\n" ""
	printf "%s\n" " -> Beginning Font removal: "
	printf "%s\n" ""
	sleep 1
	rm ${HOME}/.local/share/fonts/'MesloLGS NF Bold Italic.ttf' 
	rm ${HOME}/.local/share/fonts/'MesloLGS NF Bold.ttf' 
	rm ${HOME}/.local/share/fonts/'MesloLGS NF Italic.ttf' 
	rm ${HOME}/.local/share/fonts/'MesloLGS NF Regular.ttf'

}


if [[ $UID != 0 ]]; then
    printf "%s\n" "${color_red}ERROR:${color_normal} Please run this script with sudo"
    exit 1
fi


remove_docker
remove_fonts
sleep 1
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Uninstall complete,  make sure to reboot: 'reboot now'"
printf "%s\n" ""
exit 0

