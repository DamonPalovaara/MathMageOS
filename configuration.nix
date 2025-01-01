# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
	pipewire
  ];
  programs.git.config = { 
    enable = true;
    user.name = "DamonPalovaara";
    user.email = "dpalovaa@nmu.edu";
  };

  hardware.opengl.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Detroit";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Services
  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };
    displayManager = {
      defaultSession = "none+i3";
    };
  };

  nixpkgs.config = {
      allowUnfree = true;
      pulseaudio = true;
  };

  programs.thunar.enable = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.damon = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # PKGS
  environment.systemPackages = 
	(map (x: pkgs."${x}") 
		(builtins.filter (x: x != "") 
			(map (x: toString x) 
				(builtins.split "\n" (builtins.readFile ./packages.txt)))));
#	++ [pkgs-unstable.darktable];
#	++ (with pkgs; [libGL wget gcc gdb gnumake cmake unzip zip curl jq python3 zstd libpulseaudio pkgconf]);
  # FONTS
  fonts.packages = with pkgs; [ q
    fira-code
    font-awesome
  ];

  environment.variables.EDITOR = "alacritty";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11"; # DO NOT CHANGE! (Read original comment)

}

