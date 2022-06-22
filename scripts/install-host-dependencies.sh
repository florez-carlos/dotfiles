#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)

update() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning update: "
    printf "%s\n" ""
    sleep 1
    apt-get update -y 
    apt-get upgrade -y 
    if [ $? -ne 0 ]
    then
        printf "%s\n" "${color_red}ERROR${color_normal}: An error has occurred updating, halting..."
        exit 1
    fi
    
}

get_dependencies() {
    dependencies_file="${DOT_HOME_CONFIG}/host-dependencies.txt"
    all_dependencies_count=0
    dependencies_failures_count=0
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning Dependency Download: "
    printf "%s\n" ""
    sleep 1

    #min_version is not used here
    while IFS='=' read -r dependency min_version
    do
        
        ((++all_dependencies_count))
        printf "%s" " -> Installing $dependency: "
        
        apt-get install "$dependency" -y &> /dev/null
        dpkg -s "$dependency" &> /dev/null
        
        if [ $? -eq 0 ]
        then

            printf "%s\n" "${color_green}SUCCESS${color_normal}"

        else

            ((++dependencies_failures_count))
            printf "%s\n" "${color_red}FAILED${color_normal}"

        fi
    done < "$dependencies_file"


    if [ $dependencies_failures_count -eq 0 ]
    then
        
        printf "%s\n" ""
        printf "%s\n" "${color_green}SUCCESS${color_normal}: All dependencies have been installed successfully"

    elif [ $all_dependencies_count -eq 0 ]
    then
        
        printf "%s\n" "${color_yellow}WARNING${color_normal}: No dependencies have been installed"
        exit 1

    elif  [ $dependencies_failures_count -gt 0 ] && [ $dependencies_failures_count -eq $all_dependencies_count ]
    then
        
        printf "%s\n" "${color_red}ERROR${color_normal}: All dependencies have failed installation!"
        exit 1

    elif [ $dependencies_failures_count -gt 0 ] && [ $dependencies_failures_count -ne $all_dependencies_count ]
    then

        printf "%s\n" "${color_yellow}WARNING${color_normal}: Some dependencies have failed installation"
        exit 1

    fi

    return 1
 
}

check_dependencies() {
    
    dependencies_file="${DOT_HOME_CONFIG}/host-dependencies.txt"
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning Dependency Version Check: "
    printf "%s\n" ""
    sleep 1

    while IFS='=' read -r dependency min_version
    do
       
        installed_version="$(dpkg -s "$dependency" | grep '^Version:' | cut -d' ' -f2)"     
        dpkg --compare-versions $installed_version gt $min_version 
        
        if [ $? -ne 0 ]
        then
            printf "%s\n" "$dependency - $installed_version: ${color_red}FAIL${color_normal}"
            printf "%s\n" ""
            printf "%s\n" "${color_red}ERROR${color_normal}: $dependency installed version: $installed_version but minimum required: $min_version"
            printf "%s\n" "Proceed with manual installation of $dependency - $min_version or larger and rerun this script"
            exit 1;

        else
            printf "%s\n" "$dependency - $installed_version: ${color_green}PASS${color_normal}"
            continue
        fi


    done < "$dependencies_file"
    
    printf "%s\n" ""
    printf "%s\n" "${color_green}SUCCESS${color_normal}: All dependencies are of appropriate version"
}


copy_fonts() {

	printf "%s\n" ""
	printf "%s\n" " -> Beginning Font Install: "
	printf "%s\n" ""
	sleep 1
	mkdir -p ${HOME}/.local/share/fonts
	cp ${MODULE_HOME}/lib/powerlevel10k-media/'MesloLGS NF Bold Italic.ttf' ${HOME}/.local/share/fonts/
	cp ${MODULE_HOME}/lib/powerlevel10k-media/'MesloLGS NF Bold.ttf' ${HOME}/.local/share/fonts/
	cp ${MODULE_HOME}/lib/powerlevel10k-media/'MesloLGS NF Italic.ttf' ${HOME}/.local/share/fonts/
	cp ${MODULE_HOME}/lib/powerlevel10k-media/'MesloLGS NF Regular.ttf' ${HOME}/.local/share/fonts/
	chown -R ${USER}:${USER} ${HOME}/.local/share/fonts
	fc-cache -f -v

}

install_docker() {


	mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |sudo -H gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	echo \ "deb [arch=$(dpkg --print-architecture) \
	signed-by=/etc/apt/keyrings/docker.gpg] \
	https://download.docker.com/linux/ubuntu \
  	$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update -y
	apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
	docker run hello-world
	#groupadd docker
	adduser ${USER} docker

}


if [[ $UID != 0 ]]; then
    printf "%s\n" "${color_red}ERROR:${color_normal}Please run this script with sudo"
    exit 1
fi

update
get_dependencies
check_dependencies
copy_fonts
install_docker
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
