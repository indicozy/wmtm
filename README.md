# sway-dotfiles-script
A Bash script for Sway Window Manager with preconfigured themes:
* Windows 98/XP/7/10;
* MacOS 1.0/15.0;
* Ubuntu 20.04;
* Additional two Sway themes.
## Themes and Code are ready!
There are configs for some themes, be free to use them!
The code is WM-free, meaning **you can use it with other WMs just by adding your configs to "config" folder and editing the reload command.**



The script has several features:
* Basic GUI
* Easy and intuitive usage
* Notifications
* Auto-backup your previous config up to 8 histories at "~/Documents/sway_configs_saved"
* Hotkeys are automatically appended to the Sway config, so there is no need to manually add it to your config!

# Usage
* Ctrl+Super+Space - Open GUI of the app
* Ctrl+Super+s - Save your config to the folder ~/Documents/sway_configs_saved
* Ctrl+Super+(1-9) - change theme tho N'th theme
* Ctrl+Super+(left/right) - change theme to the next/previous one
* ./changetheme next - next theme
* ./changetheme MacOSBigSur - change to an exact theme
* ./changetheme (number) - change theme to an N'th theme
* ./changetheme goback (or fuckgoback) - if you was editing your theme and suddenly used this script which overwrites your config, this command gets your overwritten files back, up to 7 saves!
* ./changetheme fuck - well, it's just for fun, if you somehow messed up your config and want to swear at my code, feel free to do that, but I will defend myself ━╤デ╦︻(▀̿̿Ĺ̯̿̿▀̿ ̿)

### Before using a script, make sure that the "path" value is pointing to the location of the script
(I couldn't make it automatic, because Sway is launching it from Desktop)

# Installation
## Requirements
* [rofi-lbonn-wayland-git](https://github.com/lbonn/rofi) -> Menu
* Sway -> Window Manager
* Swaylock-effects
* waybar -> bar
* alacritty -> terminal
* wlogout -> logout screen
* polkit -> authentification for stacer, gparted, etc
* polkit-gnome -> required addition for polkit
* mako -> Notification daemon
* zenity -> GUI application for my script
* autotiling from https://github.com/nwg-piotr/autotiling

Link for icons/cursors/themes (Required): https://drive.google.com/drive/folders/1QrF2_8l0AQaOtExoguOcq1iMjT7dkP9Q?usp=sharing
### Optional
* [Greetd](https://git.sr.ht/~kennylevinsen/greetd) -> Login Manager
* [greetd-gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet) -> GTK-based addition for Greetd 
* zathura -> PDF (and others) reader
* thunar -> file manager
* Chromium -> browser

Preferred OS would be **Arch Linux**, since it's much easier to install packages and get same results as mine

Hope you found this repo helpful/inspirational!
If you want to tip for a coffee, I will add bitcoin/monero/dogecoin later.

P.S. FYI I'm total noob in git and bash. I made the code to be as safe as possible (so there's no rm -rf ~), yet if you have some programming skills, please check my bash script ( ͡^ ͜ʖ ͡^)
