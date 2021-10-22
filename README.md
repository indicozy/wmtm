# sway-dotfiles-script

<table border="0">
 <tr>
    <td><img src="https://user-images.githubusercontent.com/51142471/138446793-ce215d53-d9bf-45dd-936a-ebc3ee2cc62b.png" width="200" height="200"></td>
    <td><b style="font-size:30px">A Bash script for Sway Window Manager with preconfigured themes</b></td>
 </tr>
</table>

* Windows 98/XP/7/10;

* MacOS 1.0/15.0;
* Ubuntu 20.04;
* Additional two Sway themes.

The script has several features:
* Simple GUI
* Easy and intuitive usage
* Automatic install
* Customization
* Auto-backup your previous config up to 8 histories at "~/Documents/sway_configs_saved"
* Hotkeys are automatically appended to the Sway config

# Usage
* Ctrl+Super+Space - Open GUI of the app
* Ctrl+Super+s - Save your config to the folder ~/Documents/sway_configs_saved
* Ctrl+Super+(1-9) - change theme tho N'th theme
* Ctrl+Super+(left/right) - change theme to the next/previous one
* ./changetheme.sh next - next theme
* ./changetheme.sh MacOSBigSur - change to an exact theme
* ./changetheme.sh customize - start customization
* ./changetheme.sh (number) - change theme to an N'th theme
* ./changetheme.sh goback (or fuckgoback) - if you was editing your theme and suddenly used this script which overwrites your config, this command gets your overwritten files back, up to 7 saves!
* ./changetheme fuck - well, it's just for fun, if you somehow messed up your config and want to swear at my code, feel free to do that :)

# Installation
## Requirements 
**(Script can automatically install packages for Arch Linux, but for other distros feel free to open issues or pull a request)**
* [rofi-lbonn-wayland-git](https://github.com/lbonn/rofi) -> Menu
* Sway -> Window Manager
* grimshot -> Screenshot application
* Swaylock-effects -> Lock Screen
* waybar -> bar
* alacritty -> terminal
* wlogout -> logout screen
* polkit -> authentification for stacer, gparted, etc
* polkit-gnome -> required addition for polkit, preferred version is polkit-gnome-git from AUR
* mako -> Notification daemon
* zenity -> GUI application for my script
* autotiling from (nwg-piotr)[https://github.com/nwg-piotr/autotiling], can be installed by AUR
* nerd-fonts-fira-code -> icons for panels

Link for icons/cursors/themes (Required): https://drive.google.com/drive/folders/1QrF2_8l0AQaOtExoguOcq1iMjT7dkP9Q?usp=sharing
### Optional
* [Greetd](https://git.sr.ht/~kennylevinsen/greetd) -> Login Manager
* [greetd-gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet) -> GTK-based addition for Greetd 
* zathura -> PDF (and others) reader
### My personal Applications, you can change to your own at config
* thunar -> file manager
* Chromium -> browser

### Future Plans
- [X] Add customizability of Sway config (Autostart, Behaviour, Rules)
- [ ] Add Gtk-2.0, Gtk-3.0, Gtk-4.0 (if possible), and qt5ct folders
- [X] Add customizability of other Config folders (Rofi, Mako, Waybar)
- [ ] Create a Wiki and Q&A with guides on ricing sway
- [ ] Create an AUR package
- [ ] Basic logging for maintenance (Under decision, idk how even it could be helpful)

### Under consideration
- [ ] Creating a website/server similar to [gnome-look.org](https://www.gnome-look.org/) which will download themes and icons from their site + custom .config builds, and automatically add, install or delete files, themes, icons and required packages on userspace. The only obstacle is my skills, I'm only a beginner developer yet
- [ ] Creating a frontend for easier configuration, like in DEs where u can just tick which apps to autostart, which things to add and etc. However, it's much easier to configure with plain text, so there's no reason creating this feature

Preferred OS would be **Arch Linux**, since, at least for now, my code is made to install packages *only* to Arch Linux

**Please tip me for a coffee!** It would motivate a beginner programmer to study and develop the project further!

`Bitcoin: zpub6mytQoyr5y5LMfw8evkTHaUtnuac4vgNusx6bdKrrR8r59GAiPWa3zV7WGJgZAfB2Kn25MRmZ4tpLzY7WnHnSvPL4yLxs7PYjHMXjJKHipo`

`Monero: 4Ayjpc8iQtAZrZLT5PhskyFdbNgYow1h9gW3g17J7vjN3KgMCPoGCyVKD4ziTKM9S2aDdEDeYi59E6SNKqbCWjLbQGQrUH9`

Hope you found this repo helpful/inspirational!

P.S. I'm a beginner developer, if you have some bash scripting skills, please check my script, I made the code as human-readable and maintainable as much as possible

P.S.S The code is WM-agnostic, meaning **you can use fork this code to make your own theme changer for your own WM, more details will be in the Wiki (under development).**
