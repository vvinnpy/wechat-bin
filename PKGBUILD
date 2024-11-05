# Maintainer: devome <evinedeng@hotmail.com>

_pkgname="wechat"
_oriname="com.tencent.${_pkgname}"
pkgname="${_pkgname}-bin"
pkgver=4.0.0.23
pkgrel=1
pkgdesc="Connecting a billion people with calls, chats, and more"
arch=("x86_64" "aarch64" "loong64")
url="https://weixin.qq.com"
license=("proprietary")
provides=("${_pkgname}")
conflicts=("${_pkgname}" "${_pkgname}-universal")
depends=(at-spi2-core jack libpulse libxcomposite libxdamage libxkbcommon-x11 libxrandr mesa nss pango xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm)
makedepends=("patchelf")
source_x86_64=("${_pkgname}-${pkgver}-x86_64.deb::https://home-store-packages.uniontech.com/appstore/pool/appstore/${_oriname::1}/${_oriname}/${_oriname}_${pkgver}_amd64.deb")
source_aarch64=("${_pkgname}-${pkgver}-aarch64.deb::https://home-store-packages.uniontech.com/appstore/pool/appstore/${_oriname::1}/${_oriname}/${_oriname}_${pkgver}_arm64.deb")
source_loong64=("${_pkgname}-${pkgver}-loong64.deb::https://home-store-packages.uniontech.com/appstore/pool/appstore/${_oriname::1}/${_oriname}/${_oriname}_${pkgver}_loongarch64.deb")
sha256sums_x86_64=('437826a3cdef25d763f69e29ae10479b5e8b2ba080b56de5b5de63e05a8f7203')
sha256sums_aarch64=('a08b0f6c4930d7ecd7a73bd701511d9b29178dbe73ba51c04f09eb9e1b3190f7')
sha256sums_loong64=('82b8fdc861d965a836d25e6cf0881c927bd4bf3d1f04791a9202ac39efab8662')
noextract=("${_pkgname}-${pkgver}-"{x86_64,aarch64,loong64}.deb)
options=("!strip")

prepare() {
    bsdtar -xOf "${_pkgname}-${pkgver}-${CARCH}.deb" ./data.tar.xz | xz -cdT0 | tar --strip-components 4 -x "./opt/apps/${_oriname}"
    mv "files" "${_pkgname}"

    find "${_pkgname}" -type f | while read file; do
        if [[ $(file "$file") != *"ELF "* ]]; then
            chmod -x "$file"
        fi
    done

    patchelf --set-rpath '$ORIGIN' "${_pkgname}/libwxtrans.so"
    find "${_pkgname}/vlc_plugins" -type f | xargs -I {} patchelf --set-rpath '$ORIGIN:$ORIGIN/../..' {}

    sed -e "s|^Icon=.*|Icon=${_pkgname}|" \
        -e "s|^Categories=.*|Categories=Network;InstantMessaging;Chat;|" \
        "entries/applications/${_oriname}.desktop" > "${_pkgname}.desktop"
}

package() {
    install -Dm644 "${_pkgname}.desktop" "${pkgdir}/usr/share/applications/${_pkgname}.desktop"
    install -dm755 "${pkgdir}/usr/bin"   "${pkgdir}/opt"
    mv "${_pkgname}"                     "${pkgdir}/opt/${_pkgname}"
    ln -s "/opt/${_pkgname}/${_pkgname}" "${pkgdir}/usr/bin/${_pkgname}"

    for res in 16 32 48 64 128 256; do
        local _png="entries/icons/hicolor/${res}x${res}/apps/${_oriname}.png"
        install -Dm644 "$_png"           "${pkgdir}/usr/share/icons/hicolor/${res}x${res}/apps/${_pkgname}.png"
    done
}
