# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, pkgs-unstable, musnix, ... }:

{
  nix.extraOptions = ''
    trusted-users = root damon
  '';
  
  imports = [ 
    ./hardware-configuration.nix
  ];
  # MUSNIX
  musnix = {
    enable = true;
    kernel.realtime = true;
    rtcqs.enable = true;
  };
  
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ 
    xdg-desktop-portal-gtk 
    xdg-desktop-portal-wlr
  ];

  # OLLAMA
  services.ollama = {
    enable = true;
    loadModels = [
      deepseek-r1:7b
      deepseek-r1:8b
      qwen2.5-coder:7b
      qwen2.5-math:7b
    ];
    acceleration = "rocm";
    rocmOverrideGfx = "10.3.0";
    models = "/fast-storage/models";
  };
  services.open-webui.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    ''; 
  };

  services.xserver.videoDrivers = [ "nouveau" ];

  environment.sessionVariables = {
    XCURSOR_SIZE = 96;
    XCURSOR_THEME = "Bibata_Ghost";
  };
  
  # BOOT
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=2 video_nr=1,2 card_label="Canon 6D","OBS-out" exclusive_caps=1
    '';
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
  };
    
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # SERVICES
  services = {
    gvfs.enable = true;
    flatpak.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 128;
          "default.clock.max-quantum" = 128;
        };
      };
    };
    gnome.gnome-keyring.enable = true;
    # xserver = {
    #   enable = true;
    #   windowManager.i3.enable = true;
    # };
    # displayManager.defaultSession = "none+i3";
    avahi.enable = true;
  };

  # PROGRAMS
  programs = {
    thunar.enable = true;
    firefox.enable = true;
    fish.enable = true;
    steam.enable = true;
  };
  
  # PKGS  
  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };
  environment.systemPackages = 
  # Loads packages from packages.txt
	(map (x: pkgs."${x}") 
		(builtins.filter (x: x != "") 
			(map (x: toString x) 
				(builtins.split "\n" (builtins.readFile ./packages.txt)))))
  # Darktable version 5.0
  ++ [ pkgs-unstable.darktable ]
  ++ [ pkgs.nvtopPackages.amd ]
  # OBS
  ++ [(
    pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        waveform
        wlrobs
        # obs-vertical-canvas
        # obs-multi-rtmp
      ];
    }
  )];
 
  # FONTS
  fonts.packages = with pkgs; [
    fira-code
    font-awesome
  ];
  
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.rocmPackages.clr.icd ];
    };
  };

  # NETWORK
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Detroit";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; 
  };

  # USERS
  users.users.damon = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" ]; 
  };

  environment.variables.EDITOR = "wezterm";

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [ 8010 ];
    # allowedUDPPortRanges = [ { from = 32768; to = 61000; } ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11"; # DO NOT CHANGE! (Read original comment)
}

