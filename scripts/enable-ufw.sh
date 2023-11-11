#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)

if [[ $UID != 0 ]]; then
    printf "%s\n" "${color_red}ERROR:${color_normal}Please run this script with sudo"
    exit 1
fi


enable_ufw() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning enable ufw: "
    printf "%s\n" ""
    sleep 1

    ufw allow 22
    ufw allow 80
    ufw allow 443
    ufw enable

    printf "%s\n" "${color_yellow}WARNING${color_normal}: ufw has been enabled, port 22, 80, 443 are now open"
    sleep 1

}

enable_ufw
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: ufw enable complete!"
printf "%s\n" ""
exit 0
