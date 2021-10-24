# WMTM

<table border="0">
 <tr>
    <td><img src="https://user-images.githubusercontent.com/51142471/138446793-ce215d53-d9bf-45dd-936a-ebc3ee2cc62b.png" width="200" height="200"></td>
    <td><b style="font-size:30px">WM-agnostic Theme Manager</b></td>
 </tr>
</table>

## About
WM-agnostic Theme Manager made with Bash only. Simply, it copy-pastes configs and manages them. It was preconfigured to work with Sway WM but there are lots of possibilities to use with other WMs, testing now with i3-gaps and bspwm. **If you have made advances with these testing WMs, please let me know!**

**Information below is pretty old, I will update information and new features later.**

### 9 Themes are Pre-Configured
* Windows 98/XP/7/10;
* MacOS 1.0/15.0;
* Ubuntu 20.04;
* Additional two Sway themes.

The script has several features:
* Simple GUI with `zenity`
* Easy and intuitive usage
* Easy Installation script
* Easy Customization
* Auto-backup your previous config up to 8 histories at "~/Documents/wmtm_configs_saved"

## Usage
* `Ctrl+Super+Space` - Open GUI of the app
* `Ctrl+Super+s` - Save your config to the folder ~/Documents/wmtm_configs_saved
* `Ctrl+Super+(1-9)` - change theme tho N'th theme
* `Ctrl+Super+(left|right)` - change theme to the next/previous one
* `./changetheme.sh (next|prev)` - change to next or previous theme
* `./changetheme.sh <Theme Name>` - change to an exact theme
* `./changetheme.sh customize` - open customization menu
* `./changetheme.sh <number>` - change theme to an N'th theme
* `./changetheme.sh goback` (or fuckgoback) - revert changes if you have suddenly overwritten them
* `./changetheme fuck` - feel free to swear at my code if you somehow messed up your config
 
# Installation

## Requirements 
 
Copy this and try to install to your Distro:
 
    sway swaylock wlogout rofi dialog alacritty waybar zenity polkit polkit-gnome grim grimshot

### List of Required Applications 
* [rofi-lbonn-wayland-git](https://github.com/lbonn/rofi) -> Apps menu
* `sway` -> Wayland Window Manager
* `dialog` -> Terminal Interface
* `grimshot` -> Screenshots
* `swaylock` OR `swaylock-effects` -> Lock Screen
* `waybar` -> Panel
* `alacritty` -> Terminal
* `wlogout` -> GTK logout screen
* `mako` -> Notification daemon
* `zenity` -> GUI application for my script
* `autotiling` from (nwg-piotr)[https://github.com/nwg-piotr/autotiling], can be installed by AUR
* nerd-fonts-fira-code -> icons for panels
* `polkit` -> authentification for stacer, gparted, etc
* `polkit-gnome` -> required addition for polkit, preferred version is polkit-gnome-git from AUR

### Optional
* `zathura` -> PDF (and others) reader
* `zathura-pdf-poppler` -> PDF addon for `zathura`

## Future Plans
- [X] Add customizability of Sway config (Autostart, Behaviour, Rules)
- [X] Add Gtk-2.0, Gtk-3.0, Gtk-4.0 (if possible)
- [X] Add customizability of other Config folders (Rofi, Mako, Waybar)
- [ ] Create a Wiki and Q&A with guides on ricing sway and other WMs
- [ ] Basic logging for maintenance (I don't know how)

## Under consideration
- [ ] Create a website/server similar to [gnome-look.org](https://www.gnome-look.org/) which will download ready configs from my site

P.S. I'm a beginner developer, if you have some bash scripting skills, please peer-review my script. I made the code as human-readable and maintainable as much as possible, but it's still a mess.


### Bugs
* In MacOSBigSur, rofi is not working in VM
* In resources files, you cannot name archives with spaces!
* Potential: tar.\*z and zip files are being opened differently


### Notes
Yes, I'm lazy af
* [Greetd](https://git.sr.ht/~kennylevinsen/greetd) -> Login Manager
* [greetd-gtkgreet](https://git.sr.ht/~kennylevinsen/gtkgreet) -> GTK-based addition for Greetd 

