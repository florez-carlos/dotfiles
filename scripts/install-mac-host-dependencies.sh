#!/bin/zsh

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)


install_dependencies() {

  printf "%s\n" ""
  printf "%s\n" " -> Beginning Docker Install: "
  printf "%s\n" ""
  sleep 1

  cd /tmp || exit 1
  curl -LO "https://desktop.docker.com/mac/main/arm64/Docker.dmg?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-mac-arm64"
  sudo hdiutil attach Docker.dmg
  sudo /Volumes/Docker/Docker.app/Contents/MacOS/install
  sudo hdiutil detach /Volumes/Docker
  rm /tmp/Docker.dmg


  printf "%s\n" ""
  printf "%s\n" " -> Beginning Brew Dependencies Install: "
  printf "%s\n" ""
  sleep 1
  brew install minikube jq

  printf "%s\n" ""
  printf "%s\n" " -> Beginning dependencies check: "
  printf "%s\n" ""
  sleep 1

  if command -v docker >/dev/null 2>&1; then
    printf "%s\n" "-> Docker: ${color_green}PASS${color_normal}"
    sleep 1
  else
    printf "%s\n" "-> Docker: ${color_red}FAIL${color_normal}"
    sleep 1
  fi

  if command -v minikube >/dev/null 2>&1; then
    printf "%s\n" "-> Minikube: ${color_green}PASS${color_normal}"
    sleep 1
  else
    printf "%s\n" "-> Minikube: ${color_red}FAIL${color_normal}"
    sleep 1
  fi

  if command -v kubectl >/dev/null 2>&1; then
    printf "%s\n" "-> Kubectl: ${color_green}PASS${color_normal}"
    sleep 1
  else
    printf "%s\n" "-> Kubectl: ${color_red}FAIL${color_normal}"
    sleep 1
  fi

  if command -v jq >/dev/null 2>&1; then
    printf "%s\n" "-> jq: ${color_green}PASS${color_normal}"
    printf "%s\n" ""
    sleep 1
  else
    printf "%s\n" "-> jq: ${color_red}FAIL${color_normal}"
    printf "%s\n" ""
    sleep 1
  fi

}

copy_fonts() {

  printf "%s\n" ""
  printf "%s\n" " -> Beginning Font Install: "
  printf "%s\n" ""
  sleep 1

  cp ${MODULE_HOME}/lib/*.ttf /Library/Fonts/

  printf "%s\n" ""
  printf "%s\n" "⚠️  ${color_yellow}Pending:${color_normal} manually set your terminal font to: MesloLGS"
  printf "%s\n" "⚠️  ${color_yellow}Pending:${color_normal} manually run Docker Desktop from Applications"
  printf "%s\n" ""
  sleep 1

}


install_dependencies
copy_fonts
