function rb --wraps='nixos-rebuild --flake ~/.dotfiles' --wraps='sudo nixos-rebuild --flake ~/.dotfiles'
sudo nixos-rebuild switch --flake ~/.dotfiles
end
