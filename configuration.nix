# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix  
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for Steam VR elevated privileges (see https://wiki.nixos.org/wiki/VR)
  boot.kernelPatches = [
  {
    name = "amdgpu-ignore-ctx-privileges";
    patch = pkgs.fetchpatch {
      name = "cap_sys_nice_begone.patch";
      url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
      hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
    };
  }
];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm = {
    enable = true;
  #  settings = {
  #    "org.gnome.desktop.interface" = {
  #      primary-monitor = "DP-2";   # ← dein *Schreibtisch-Monitor*
  #    };
  #  };
  };
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fabian = {
    isNormalUser = true;
    description = "Fabian";
    extraGroups = [ "networkmanager" "wheel" "plugdev" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Extra User for playing VR games
  users.users.vruser = {
    isNormalUser = true;
    description = "VR User";
    group = "users";
    createHome = true;
    extraGroups = [ "video" "input" ];  # Hinzufügen der nötigen Gruppen für VR
  };

  # DMS (Dank material shell)
  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;             # Systemd service for auto-start
      restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
    };
    
    # Core features
    # enableSystemMonitoring = true;     # System monitoring widgets (dgop)
    # enableClipboard = true;            # Clipboard history manager
    # enableVPN = true;                  # VPN management widget
    # enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
    # enableAudioWavelength = true;      # Audio visualizer (cava)
    # enableCalendarEvents = true;       # Calendar integration (khal)
  };

  # Polkit-Regeln für udisks2 hinzufügen
  environment.etc."polkit-1/rules.d/00-udisks2.rules".text = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.udisks2.") == 0 && subject.isInGroup("users")) {
          return polkit.Result.YES;
      }
    });
  '';

  # Install firefox.
  programs.firefox.enable = true;

  # Enable Hyprland
  programs.hyprland.enable = true;

  # STEAM
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # programs.gamescope ={
  #   enable = true;
  #   capSysNice = true;
  # };

  # programs.steam = let
  #   patchedBwrap = pkgs.bubblewrap.overrideAttrs (o: {
  #     patches = (o.patches or []) ++ [
  #       # ./bwrap.patch
  #       ./bwrap.patch
  #     ];
  #   });
  # in {
  #   enable = true;
  #   package = pkgs.steam.override {
  #     buildFHSEnv = (args: ((pkgs.buildFHSEnv.override {
  #       bubblewrap = patchedBwrap;
  #     }) (args // {
  #       extraBwrapArgs = (args.extraBwrapArgs or []) ++ [ "--cap-add ALL" ];
  #     })));
  #   };
  # };



  # services.wivrn = {
  #   enable = true;
  #   openFirewall = true;

  #   # Write information to /etc/xdg/openxr/1/active_runtime.json, VR applications
  #   # will automatically read this and work with WiVRn (Note: This does not currently
  #   # apply for games run in Valve's Proton)
  #   defaultRuntime = true;


  #   # Run WiVRn as a systemd service on startup
  #   # autoStart = true;

  #   # If you're running this with an nVidia GPU and want to use GPU Encoding (and don't otherwise have CUDA enabled system wide), you need to override the cudaSupport variable.
  #   # package = (pkgs.wivrn.override { cudaSupport = true; });

  #   # You should use the default configuration (which is no configuration), as that works the best out of the box.
  #   # However, if you need to configure something see https://github.com/WiVRn/WiVRn/blob/master/docs/configuration.md for configuration options and https://mynixos.com/nixpkgs/option/services.wivrn.config.json for an example configuration.
  # };


  hardware.steam-hardware.enable = true;

  hardware.amdgpu.overdrive.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # VR
  # programs.alvr = {
  #   enable = true;
  #   openFirewall = true;
  # };

  programs.alvr = {
    enable = true;

    openFirewall = true;

    # Pin to 20.13.0 due to https://github.com/alvr-org/ALVR/issues/3134
    package = pkgs.alvr.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "20.13.0";

        src = pkgs.fetchFromGitHub {
          owner = "alvr-org";
          repo = "ALVR";
          tag = "v${finalAttrs.version}";
          fetchSubmodules = true;
          hash = "sha256-h7/fuuolxbNkjUbqXZ7NTb1AEaDMFaGv/S05faO2HIc=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit (finalAttrs) src;
          hash = "sha256-A0ADPMhsREH1C/xpSxW4W2u4ziDrKRrQyY5kBDn//gQ=";
        };
      }
    );
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gh
    git
    google-chrome
    obsidian
    whatsapp-electron
    vscode
    neovim
    vlc

    # Nix Development
    nixd

    # Gaming
    protonplus
    gamescope
    mangohud
    goverlay

    lact

    # Hyprland
    hyprland
    waybar
    rofi
    alacritty
    kitty
    xwayland
    swaynotificationcenter
    qt5.qtwayland
    qt6.qtwayland
    polkit_gnome
    gnome-keyring

    xdg-desktop-portal
    kdePackages.xdg-desktop-portal-kde
    # xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland  # Hyprland-spezifisches Portal

    hyprshot

    nwg-look

    bibata-cursors
    papirus-icon-theme
    
    # Fonts
    cantarell-fonts
    dejavu_fonts
    inconsolata
    nerd-fonts.fira-code

    xnviewmp

    # QT Themes
    kdePackages.qt6ct
    # GTK Themes
    adw-gtk3

    blueman

    # ROCM
    rocmPackages.rocminfo
    rocmPackages.rocm-smi

    distrobox
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.kdePackages.xdg-desktop-portal-kde
    # xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-hyprland
  ];

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
    };
  };

  # 🔧 Fix für leere "Öffnen mit…" / MIME-Listen in Dolphin
  environment.etc."/xdg/menus/applications.menu".text =
    builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";


  # Set up Wayland
  environment.variables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    GTK_THEME = "Adwaita-dark";
    # WAYLAND_DISPLAY = "wayland-1"; # TODO: wayland-1 ? Siehe hyprland.conf
  };

  # Notification daemon über hpyrland.conf starten
  systemd.services.swaynotificationcenter = {
    enable = false;
  };

  services.avahi = {
    nssmdns4 = true;
    enable = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  # For Distrobox
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # FLAKES
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.udisks2 = {
    enable = true;
  };

  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.udev.packages = [
    pkgs.steam
    # pkgs.steamvr
  ];

  systemd.services.lact = {
    description = "AMDGPU Control Daemon";
    after = ["multi-user.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    enable = true;
  };

  services.flatpak.enable = true;

  programs.seahorse.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 5353 9757 ]; # WiVRn
    allowedTCPPorts = [ 9757 ];      # WiVRn
  };
 

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
