# Maintainer: devome <evinedeng@hotmail.com>

_pkgname="wechat"
pkgname="${_pkgname}-bin"
pkgver=4.0.1.7
pkgrel=1
pkgdesc="WeChat from Tencent | 微信官方版"
arch=("x86_64" "aarch64" "loong64")
url="https://linux.weixin.qq.com"
license=("custom:Software License and Service of Tencent Weixin")
provides=("${_pkgname}"{,-universal})
conflicts=("${_pkgname}"{,-universal})
replaces=("${_pkgname}-universal"{,-privilege})
depends=(at-spi2-core jack libpulse libxcomposite libxdamage libxkbcommon-x11 libxrandr mesa nss pango xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm)
optdepends=("noto-fonts-cjk: Chinese font support"
            "noto-fonts-emoji: emoji support")
source=("LICENSE-zh_CN.html::https://weixin.qq.com/agreement?lang=zh_CN"
        "LICENSE-zh_HK.html::https://weixin.qq.com/agreement?lang=zh_HK"
        "LICENSE-zh_TW.html::https://weixin.qq.com/agreement?lang=zh_TW"
        "LICENSE-en.html::https://www.wechat.com/mobile/en/service_terms.html")
source_x86_64=("${_pkgname}-${pkgver}-x86_64.deb::https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.${_pkgname}/com.tencent.${_pkgname}_${pkgver}_amd64.deb")
source_aarch64=("${_pkgname}-${pkgver}-aarch64.deb::https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.${_pkgname}/com.tencent.${_pkgname}_${pkgver}_arm64.deb")
source_loong64=("${_pkgname}-${pkgver}-loong64.deb::https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.${_pkgname}/com.tencent.${_pkgname}_${pkgver}_loongarch64.deb")
sha256sums=('SKIP' 'SKIP' 'SKIP' 'SKIP')
sha256sums_x86_64=('bfd5a2a320280148ff35f7a9d36d1ba98f4a685f41df2518fbb10f7636df3bb2')
sha256sums_aarch64=('403fbcc7cb2cd55546e018a8b6e6685aca734c9019b2bdcc09c19b6608e6385e')
sha256sums_loong64=('33eabe2abfd467699d857aa9807fd73c17f058c8d547fdc3141ee078ea68adca')
noextract=("${_pkgname}-${pkgver}-"{x86_64,aarch64,loong64}.deb)
options=("!strip")

prepare() {
    bsdtar -xOf "${_pkgname}-${pkgver}-${CARCH}.deb" data.tar.xz | bsdtar -xmf- --strip-components 4 --exclude "opt/apps/com.tencent.${_pkgname}/info" "opt/apps/com.tencent.${_pkgname}"
    mv "files" "${_pkgname}"
    while read file; do
        if [[ $(file -b "$file") != "ELF "* ]]; then
            chmod -x "$file"
        fi
    done <<< "$(find "${_pkgname}" -type f)"
        
    sed -e "s|^Icon=.*|Icon=${_pkgname}|" \
        -e "s|^Categories=.*|Categories=Network;InstantMessaging;Chat;|" \
        -e "s|^Exec=.*|Exec=env 'QT_QPA_PLATFORM=wayland;xcb' QT_AUTO_SCREEN_SCALE_FACTOR=1 /usr/bin/${_pkgname} %U|" \
        "entries/applications/com.tencent.${_pkgname}.desktop" > "${_pkgname}.desktop"
}

package() {
    install -Dm644 LICENSE-*          -t "${pkgdir}/usr/share/licenses/${pkgname}"
    install -Dm644 "${_pkgname}.desktop" "${pkgdir}/usr/share/applications/${_pkgname}.desktop"
    install -dm755 "${pkgdir}/usr/bin"   "${pkgdir}/opt"
    mv "${_pkgname}"                     "${pkgdir}/opt/${_pkgname}"
    ln -s "/opt/${_pkgname}/${_pkgname}" "${pkgdir}/usr/bin/${_pkgname}"
    for res in 16 32 48 64 128 256; do
        local _png="entries/icons/hicolor/${res}x${res}/apps/com.tencent.${_pkgname}.png"
        install -Dm644 "$_png"           "${pkgdir}/usr/share/icons/hicolor/${res}x${res}/apps/${_pkgname}.png"
    done
}
