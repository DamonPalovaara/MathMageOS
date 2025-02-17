{ config, pkgs, ... }:

{
  home.username = "damon";
  home.homeDirectory = "/home/damon";

  home.packages = [
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  
  # dotfiles
  home.file = {
    # ".screenrc".source = dotfiles/screenrc;
  };

  gtk = {
    enable = true;  
    cursorTheme = {
      package = pkgs.bibata-cursors-translucent;
      size = 32;
      name = "Bibata_Ghost";
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    x11.defaultCursor = "Bibata_Ghost";
    package = pkgs.bibata-cursors-translucent;
    name = "Bibata_Ghost";
    size = 96;
  };
  
  programs.git = { 
    enable = true;
    userName = "DamonPalovaara";
    userEmail = "dpalovaa@nmu.edu";
    extraConfig = {
      push = { autoSetupRemote = true; };
    };
  };


  home.sessionVariables = {
    EDITOR = "hx";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # DONT CHANGE
  home.stateVersion = "24.11";
}
