#!/bin/bash

# A full package URL looks like this:
#   https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb

set -euo pipefail

PWD=$(pwd)
arch=$(uname -m)
aur_package_name=${PACKAGE_NAME:-wechat-bin}
name=
version=
hash=

get_latest() {
  declare -A arches=(
    ['x86_64']='x86_64'
    ['aarch64']='arm64'
    ['loong64']='LoongArch'
  )

  if [[ -z ${arches[$arch]} ]]; then
    echo "unsupported arch: ${arch}"
    exit 1
  fi

  local name_prefix='wechat-'
  local url_prefix='https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_'

  local url="${url_prefix}${arches["${arch}"]}.deb"
  local name_temp="${name_prefix}unknown-${arch}.deb.temp"
  curl -Lo "${name_temp}" "${url}"
  version=$(
    bsdtar -xOf "${name_temp}" ./control.tar.xz |
      xz -cdT0 |
      tar -xO ./control |
      sed -n 's/^Version: \+\(.\+\)$/\1/p'
  )
  name="${name_prefix}${version}-${arch}.deb"
  mv "$name_temp" "$name"

  hash=$(sha256sum "${name}" | cut -d ' ' -f1)

  echo "latest version:"
  echo "pkgver=${version}"
  printf "sources_%s=(\n    '%s::%s'\n)\n" \
    "${arch}" "${name}" \
    "${url}"
  printf "sha256sums_%s=(\n    '%s'\n)\n" \
    "${arch}" "${hash}"
}

install() {
  #  local version_installed=$(grep 'pkgver=' "$PWD/PKGBUILD" | awk -F '=' '{print $2}')
  local version_installed=$(pacman -Qi ${aur_package_name} \
      | grep Version \
      | cut -d ":" -f2 \
      | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/-[^-]*$//')
  if [ "$(vercmp "${version}" "${version_installed}")" == 1 ]; then
    sed -e "s#pkgver=\(.*\)#pkgver=${version}#" \
        -e "s#source_${arch}=\(.*\)#source_${arch}=(\${_pkgname}-\${pkgver}-x86_64.deb::file://$PWD/$name)#" \
        -i "${PWD}/PKGBUILD"
    echo "install: [$version]"
    makepkg -si --skipinteg
    git reset --hard
    #git clean -fdx
  else
    echo "[$version_installed] Current version is up to date"
  fi
}

get_latest
install
exit 0
