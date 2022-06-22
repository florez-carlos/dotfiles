#!/bin/bash

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)

add_ppa() {

    apt-get install software-properties-common curl sudo build-essential -y
    add-apt-repository ppa:neovim-ppa/unstable
    apt-get update -y
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -


}


update() {

    printf "%s\n" ""
    printf "%s\n" " -> Beginning update: "
    printf "%s\n" ""
    sleep 1
    apt-get update -y 
    apt-get upgrade -y 
    yes Y | unminimize
    if [ $? -ne 0 ]
    then
        printf "%s\n" "${color_red}ERROR${color_normal}: An error has occurred updating, halting..."
        exit 1
    fi
    
}

get_dependencies() {
    
    dependencies_file="${DOT_HOME_CONFIG}/dependencies.txt"
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
    
    dependencies_file="${DOT_HOME_CONFIG}/dependencies.txt"
    
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


set_defaults() {
    
    alternatives_file="${DOT_HOME_CONFIG}/defaults.txt"
    
    printf "%s\n" ""
    printf "%s\n" " -> Beginning Update Alternatives: "
    printf "%s\n" ""
    sleep 1

    while IFS='=' read -r alternative location
    do
        update-alternatives --set $alternative $location

        if [ $? -eq 0 ]
        then
            printf "%s\n" "$alternative: ${color_green}SUCCESS${color_normal}"   
        else
            printf "%s\n" "$alternative: ${color_red}ERROR${color_normal}"   
            printf "%s\n" ""
            printf "%s\n" "${color_red}ERROR${color_normal}: An error occurred with update alternatives for $alternative"   
            printf "%s\n" ""
            exit 1
        fi

    done < "$alternatives_file"
    


}



if [[ $UID != 0 ]]; then
    printf "%s\n" "Please run this script with sudo:"
    printf "%s\n" "sudo $0"
    exit 1
fi

update
add_ppa
get_dependencies
check_dependencies
set_defaults
printf "%s\n" ""
printf "%s\n" "${color_green}SUCCESS${color_normal}: Installation complete!"
printf "%s\n" ""
exit 0
