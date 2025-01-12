# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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
  };
    
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  # SERVICES
  services = {
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
          "default.clock.quantum" = 32;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 32;
        };
      };
    };
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };
    displayManager.defaultSession = "none+i3";
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
  ++ [pkgs-unstable.darktable]
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
    graphics.enable = true;
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
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.variables.EDITOR = "alacritty";

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [ 8008 8009 8010 ];
    allowedUDPPortRanges = [ { from = 32768; to = 61000; } ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11"; # DO NOT CHANGE! (Read original comment)
}

