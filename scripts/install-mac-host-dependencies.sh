#!/bin/zsh

color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_normal=$(tput sgr0)


install_docker() {

  printf "%s\n" ""
  printf "%s\n" " -> Beginning Rosetta Install: "
  printf "%s\n" ""
  sleep 1

  /usr/sbin/softwareupdate --install-rosetta --agree-to-license

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
  printf "%s\n" " -> Beginning dependencies check: "
  printf "%s\n" ""
  sleep 1

  if [[ "$(uname -m)" == "arm64" ]] && [[ "$(uname -s)" == "Darwin" ]]; then
    if arch -x86_64 /usr/bin/true 2>/dev/null; then
      printf "%s\n" ""
      printf "%s\n" " -> Rosetta: ${color_green}PASS${color_normal}"
      sleep 1
    else
      printf "%s\n" ""
      printf "%s\n" " -> Rosetta: ${color_red}FAIL${color_normal}"
      sleep 1
    fi
  fi

  if command -v docker >/dev/null 2>&1; then
    printf "%s\n" " -> Docker: ${color_green}PASS${color_normal}"
    printf "%s\n" ""
    sleep 1
  else
    printf "%s\n" " -> Docker: ${color_red}FAIL${color_normal}"
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


install_docker
copy_fonts
