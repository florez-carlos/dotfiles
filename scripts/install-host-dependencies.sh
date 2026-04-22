#!/bin/bash
 
color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)
 
#Some dependencies require trusted keys
add_trusted_keys() {
 
    dependencies_file="${DOT_HOME_CONFIG}/host-dependencies.txt"
    
    while IFS='=' read -r dependency min_version
    do
 
        if [ "$dependency" == "kubectl" ]
        then
            kubectl_version="v$min_version"
            break
        fi
    done < "$dependencies_file"
 
    arch=$(dpkg --print-architecture)
    os_name=$(. /etc/os-release && echo "$ID") 
    os_version_codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    sudo mkdir -p /etc/apt/keyrings
    sudo chmod 755 /etc/apt/keyrings
 
    curl -fsSL https://pkgs.k8s.io/core:/stable:/${kubectl_version}/deb/Release.key | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg >/dev/null
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg >/dev/null
 
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${kubectl_version}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
 
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${os_version_codename} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
 
}
 
update() {
 
    printf "%s\n" ""
    printf "%s\n" " -> Beginning update: "
    printf "%s\n" ""
    sleep 1
    sudo apt-get update -y 
    sudo apt-get upgrade -y 
    if [ $? -ne 0 ]
    then
        printf "%s\n" "${color_red}ERROR${color_normal}: An error has occurred updating, halting..."
        exit 1
    fi
    
}
 
get_apt_dependencies() {
 
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
 
        if [ "$dependency" == "minikube" ]
        then
            printf "%s\n" " -> Installing $dependency: ${color_yellow}SKIP${color_normal} (Needs to be installed later)"
            continue
        fi
        
        printf "%s" " -> Installing $dependency: "
        
        sudo apt-get install "$dependency" -y &> /dev/null
        dpkg -s "$dependency" &> /dev/null
        
        if [ $? -eq 0 ]
        then
 
            printf "%s\n" "${color_green}INSTALLED${color_normal}"
 
        else
 
            printf "%s\n" "${color_red}FAILED${color_normal}"
            printf "%s\n" "${color_red}A dependency has failed installation, aborting${color_normal}"
            exit 1
 
        fi
    done < "$dependencies_file"
 
    printf "%s\n" ""
    printf "%s\n" "${color_green}SUCCESS${color_normal}: All dependencies have been installed"
    sleep 1
 
 
}
 
check_apt_dependencies() {
    
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
            printf "%s\n" "Proceed with manual installation of $dependency - $min_version or larger"
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
	cp ${MODULE_HOME}/lib/'MesloLGS NF Bold Italic.ttf' ${HOME}/.local/share/fonts/
	cp ${MODULE_HOME}/lib/'MesloLGS NF Bold.ttf' ${HOME}/.local/share/fonts/
	cp ${MODULE_HOME}/lib/'MesloLGS NF Italic.ttf' ${HOME}/.local/share/fonts/
	cp ${MODULE_HOME}/lib/'MesloLGS NF Regular.ttf' ${HOME}/.local/share/fonts/
	sudo chown -R ${USER}:${USER} ${HOME}/.local/share/fonts
	fc-cache -f -v
 
}
 
#This has special installation steps
install_minikube() {
 
    printf "%s\n" ""
    printf "%s\n" " -> Beginning special installation -> minikube: "
    printf "%s\n" ""
    sleep 1
 
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
    rm -f minikube_latest_amd64.deb
 
}
 
 
add_trusted_keys
update
get_apt_dependencies
install_minikube
check_apt_dependencies
copy_fonts
 
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
