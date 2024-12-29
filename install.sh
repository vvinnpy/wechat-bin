#!/bin/bash

# A full package URL looks like this:
#   https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb

set -euo pipefail

PWD=$(pwd)
arch=$(uname -m)
name=
version=
hash=

get_latest() {
  declare -A arches=(
    ['x86_64']='x86_64'
    ['aarch64']='arm64'
    ['loong64']='LoongArch'
  )

  local name_prefix='wechat-'
  local url_prefix='https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_'

  local url="${url_prefix}${arches["${arch}"]}.deb"
  local name_temp="${name_prefix}${arch}.deb.temp"
  curl -Lo "${name_temp}" "${url}"
  version=$(
    bsdtar -xOf "${name_temp}" ./control.tar.xz |
      xz -cdT0 |
      tar -xO ./control |
      sed -n 's/^Version: \+\(.\+\)$/\1/p'
  )
  sha256sum_deb=$(sha256sum "${name_temp}")
  hash="${sha256sum_deb::64}"

  name="${name_prefix}${version}-${arch}.deb"
  mv "$name_temp" "$name"

  echo "pkgver=${version}"
  printf "sources_%s=(\n    '%s::%s'\n)\n" \
    "${arch}" "${name}" \
    "${url}"
  printf "sha256sums_%s=(\n    '%s'\n)\n" \
    "${arch}" "${hash}"
}

install() {
  version_current=$(grep 'pkgver=' "$PWD/PKGBUILD" | awk -F '=' '{print $2}')
  if [ $(vercmp "${version}" "${version_current}") == 1 ]; then
    sed -i "s/pkgver=${version_current}/pkgver=${version}/g" "${PWD}/PKGBUILD"
    sed -i "s#source_${arch}=\(.*\)#source_${arch}=(\${_pkgname}-\${pkgver}-x86_64.deb::file://$PWD/$name)#" "${PWD}/PKGBUILD"
    echo "install: [$version_current]"
    makepkg -si --skipinteg
  else
    echo "[$version_current] is the latest version"
  fi
}

get_latest
install
