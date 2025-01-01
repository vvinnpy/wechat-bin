## 安装
### 1. 手动安装
```shell
git clone https://gitee.com/evine/wechat-bin.git
cd wechat-bin
makepkg -si
```
### 2. 使用 paru
- 复制 `/etc/paru.conf` 到 `$XDG_CONFIG_HOME/paru/paru.conf` ( 默认为 `$HOME/.config/paru/paru.conf` )
- 添加 PKGBUILD 仓库
  ```properties
  # file：$XDG_CONFIG_HOME/paru/paru.conf
  #......
  
  #
  # Binary OPTIONS
  #
  #[bin]
  #FileManager = vifm
  #MFlags = --skippgpcheck
  #Sudo = doas

  # PKGBUILD 仓库
  [evine]
  Url = https://gitee.com/evine/wechat-bin
  ```
- 安装 `wechat-bin`
  ```shell
  paru && paru -S wechat-bin
  ```
- PKGBUILD 仓库优先级高于 AUR, 可使用 paru 正常升级

## 升级

```shell
cd wechat-bin
git pull
makepkg -si
```

## 打包说明

- 缓存默认保存路径~/.xwechat和$XDG_DOCUMENTS_DIR/xwechat_files。
- loong64需要安装liblol。

## 如何切换

在不同打包方式的WeChat间切换，请先确保：

- 已将旧的~/.xwechat、$XDG_DOCUMENTS_DIR/xwechat_files和~/.local/share/applications/wechat.desktop删除（如果前两个不是软连接的话可以保留）；
- 卸载其他形式封装的微信；
- 主机上没有任何运行中的或残留的微信进程。

## 环境变量

- 如果无法输入中文，则需要从菜单编辑器为其添加环境变量QT_IM_MODULE，比如：QT_IM_MODULE=fcitx（不是fcitx5）或QT_IM_MODULE=ibus。
如果高分辨率比例有问题，也可以从菜单编辑器中为其增加环境变量QT_AUTO_SCREEN_SCALE_FACTOR=1（自动缩放），或者设置指定的缩放比例QT_SCALE_FACTOR，比如QT_SCALE_FACTOR=1.5（两个变量不要同时设置）。
- 微信目前尚不支持从原生wayland启动，如果从菜单无法启动，从命令行启动出现'wechat' terminated by signal SIGSEGV (Address boundary error)错误的，需要添加环境变量'QT_QPA_PLATFORM=wayland;xcb'（注意必须有单引号）。从4.0.0.30-2起默认已经加了这个变量，但如果在更新到此版本之前，你的~/.local/share/applications/wechat.desktop已经存在了则需要你自己手动从菜单编辑器或直接编辑该文件添加一下。
- 如果你的系统没有菜单编辑器，也可以自行将/usr/share/applications/wechat.desktop复制为~/.local/share/applications/wechat.desktop（菜单编辑器其实修改的也是家目录下的这个文件），然后编辑Exec=所在行，比如设置输入法为fcitx、设置自动缩放并添加x11支持：Exec=env QT_IM_MODULE=fcitx QT_AUTO_SCREEN_SCALE_FACTOR=1 'QT_QPA_PLATFORM=wayland;xcb' /usr/bin/wechat %U。
- 对于多屏幕且屏幕分辨率不一致的，可以设置环境变量QT_AUTO_SCREEN_SCALE_FACTOR=1（自动缩放），也可以设置QT_SCREEN_SCALE_FACTORS手动指定不同屏幕不同的缩放比例，比如'QT_SCREEN_SCALE_FACTORS=1;1.5'（注意必须有单引号，且XXXX_SCALE_FACTOR的3个变量不要同时设置），表示第一块屏幕的显示比例是100%，第二块屏幕的显示比例是150%。
添加或调整环境变量后需要退出微信并重新从菜单打开方可生效。
- 如果安装了中文字体仍然乱码，请按上述方式为其增加环境变量：`LANG=zh_CN.UTF-8`。

## 如何多开

- 自行安装好bubblewrap: sudo pacman -Sy bubblewrap；
- 新建文件夹${HOME}/.xwechat2和${HOME}/documents/xwechat_files2（假设你的$XDG_DOCUMENTS_DIR目录为${HOME}/documents，如不是请自行修改，下方命令亦如此）；
- 复制/usr/share/applications/wechat.desktop为~/.local/share/applications/wechat2.desktop，并修改后者的Name Name[zh_CN] Exec三行为（自行按前面的说明添加QT_IM_MODULE以及其他环境变量）：
```desktop
Name=wechat(2)
Name[zh_CN]=微信（双开）
Exec=env 'QT_QPA_PLATFORM=wayland;xcb' QT_AUTO_SCREEN_SCALE_FACTOR=1 /usr/bin/bwrap --bind / / --dev-bind /dev /dev --bind ${HOME}/.xwechat2 ${HOME}/.xwechat --bind ${HOME}/documents/xwechat_files2 ${HOME}/documents/xwechat_files /usr/bin/wechat %U
```
-  根据你所使用的桌面的不同重建desktop文件缓存，当然重启系统也可以。然后从菜单中的微信（双开）启动即可，如需多开增加序号以此类推，反正一个原则，确保每个微信使用不同的路径来映射掉默认的~/.xwechat和$XDG_DOCUMENTS_DIR/xwechat_files。

## 其他说明

- 如有字体显示问题，可自行按需安装noto-fonts-cjk和noto-fonts-emoji。
- 如果能出现扫码界面，说明上述问题你都已经解决了。如果还是无法登陆，提示“登陆错误”或提示“未通过安全验证，你的微信暂未登陆上该新设备”则是账号问题，因为目前微信Linux版还处于测试期间，出现问题很正常，此类问题请在微信Linux版官方交流QQ群 736511883 向管理员反馈，私聊提供微信号并在手机版微信处上传日志：我->设置->帮助与反馈->右上角扳手按钮->上传日志。
- 有些账号在新设备上登陆需要进行安全校验，完成安全校验以后需要再一次扫码方可成功登陆。如果再次扫码还是无法登陆，也找微信Linux版官方交流QQ群 736511883 管理员。
- 最新版已可以：拖放文件发送，引用消息，截图（wayland环境亦可用），深色模式（需要手动设置），收藏、发表朋友圈、查看朋友的朋友圈相册、管理所有聊天中的文件、通讯录管理、视频号、小程序、浮窗，使用系统浏览器打开网页，自动登陆，自动语音转文字，截图快捷键和锁定快捷键等。
- 功能建议（也包括不是打包造成的问题）请不要在这里提交，请直接向官方反馈：微信左下角菜单->意见反馈。
