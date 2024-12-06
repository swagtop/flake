{ lib, config, pkgs, pkgs-unstable, ... }:

# Add unstable channel with:
# sudo nix-channel --add \
# https://nixos.org/channels/nixos-unstable nixpkgs-unstable
# sudo nix-channel --update
let
  gnomeSettings = [{
    settings = {
      "org/gnome/desktop/peripherals/keyboard" = {
        repeat-interval = lib.gvariant.mkUint32 30;
        delay = lib.gvariant.mkUint32 250;
      };
      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;
        gtk-enable-primary-paste = false;
        gtk-theme = "adw-gtk3-dark";
        color-scheme = "prefer-dark";
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
      };
      "org/gnome/settings/daemon/plugins/color" = {
        night-light-enable = true;
      };
      "org/gnome/desktop/peripherals/mouse" = {
        speed = lib.gvariant.mkDouble "-1.0";
      };
      "org/gnome/desktop/background" = {
        primary-color = "#000000";
      };
    };
  }];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Compile all packages locally.
  # nix.settings.substitute = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Generic hostname. 
  networking.hostName = "nixos";
  # Set real hostname in hardware-configuration.nix with:
  # networking.hostName = lib.mkForce "real_hostname"
  
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;  
    
  # Get latest Linux kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.libinput.enable = true;

  # Enable GNOME, GDM and use gnomeSettings.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.dconf.profiles.user.databases = gnomeSettings;
  programs.dconf.profiles.gdm.databases = gnomeSettings;
  environment.variables = {
    GNOME_SHELL_SLOWDOWN_FACTOR = "0.75";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };
  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.thedb = {
    isNormalUser = true;
    description = "thedb";
    extraGroups = [ "networkmanager" "wheel" "keyd" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Nix env stuff.
    nix-search-cli
    nix-index

    # Dev env stuff.
    alacritty
    zellij
    helix
    yazi
    lazygit
    vscode
    git
    gh
    valgrind

    # Language servers and co.
    rust-analyzer
    clang-tools
    lldb
    nil
    bash-language-server
    
    # Compiler stuff.
    gnumake
    rustup
    gcc
    pkg-config
    steam-run
    man-pages
    man-pages-posix
    glibc.dev

    # Python and its packages, relevant tools.
    uv
    (python312.withPackages (ps: with ps; [
      pyyaml
      python-lsp-ruff
    ]))
        
    # System tools.
    keyd
    wget
    zip
    unzip
    fastfetch
    btop
    caligula
    pipes

    # Gnome stuff.
    gparted
    flatpak
    adw-gtk3
    wayland
    xwayland
    wayland-protocols
    linux-firmware
  ];

  # nixpkgs.config.packageOverrides = pkgs: {
  #   gnome-shell = pkgs-unstable.gnome-shell;
  #   mutter = pkgs-unstable.mutter;
  #   gdm = pkgs-unstable.gdm;
  # };

  # Some programs need SUID wrappers, can be configured further or are started 
  # in user sessions. 
  # programs.mtr.enable = true; 
  # programs.gnupg.agent = { 
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.dbus.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
      	ids = ["*"];
      	settings = {
          main = { capslock = "esc"; };
        };
      };
    };
  };

  # Flatpak and flathub, and adw-gtk3 theme for flatpaks.
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists \
      flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8000 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  system.autoUpgrade = {
    enable = true;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "09:00";
    randomizedDelaySec = "45min";
  };

  # NixOS store optimization and garbage collection.
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  }; 

  # Bash aliases.
  programs.bash.shellAliases = {
    # Update.
    ud = "sudo nix flake update --flake ~/.config/flake";

    # Rebuild.
    rb = "sudo nixos-rebuild switch --flake ~/.config/flake";

    # Edit config, and hardware config.
    ec = "hx ~/.config/flake/hosts/$(hostname)/configuration.nix";
    ehc = "hx ~/.config/flake/hosts/$(hostname)/hardware-configuration.nix";

    # Python.
    py = "python";

    # Activate python venv.
    venv = "source .venv/bin/activate";

    # Nix commands.
    ns = "nix-shell";
    ni = "nix-index";
    nl = "nix-locate";

    # Zellij.
    zj = "zellij";

    # Lazygit.
    lg = "lazygit";

    # Fastfetch.
    ff = "fastfetch";

    # Pipes.
    pipes = "pipes.sh -t 0 -c 1 -c 2 -c 3 -c 4 -c 5 -c 6 -c";
  };

  programs.bash.promptInit = ''
    # Set editor to Helix.
    EDITOR=hx

    if [ "$EUID" -ne 0 ]
    then
      # Root, red prompt
      PS1='\[\e[1;32m\]\u \w € \[\e[0;0m\]'
    else
      # Normal user, green prompt
      PS1='\[\e[1;31m\]\u \w £ \[\e[0;0m\]'
    fi

    # Enable directory navigation with Yazi.
    function y() {
    	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    	yazi "$@" --cwd-file="$tmp"
    	if cwd="$(command cat -- "$tmp")" &&\
        [ -n "$cwd" ] &&\
        [ "$cwd" != "$PWD" ]
      then
    		builtin cd -- "$cwd"
    	fi
    	rm -f -- "$tmp"
     }
  '';

  # Enable dynamic linking.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Bevy dependencies
    alsa-utils
    alsa-lib
    pkg-config
    udev
    libudev0-shim
    vulkan-loader
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi
    rustup
    steam-run
    stdenv.cc.cc.lib
    glibc.dev
  ];

  # Extra fonts.
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];
}
