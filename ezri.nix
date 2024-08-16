# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  users.users.ezri = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };
  home-manager.users.ezri = { pkgs, ... }: {
    home.packages = with pkgs; [
      croc
      firefox
      tree
      hyfetch
      htop
      dig
      mtr
      aerc
      wget
      curl
      signal-desktop
     ];
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];
      shellAliases = {
        ll = "ls -l";
	update = "sudo nix-channel --upgrade";
        upgrade = "sudo nixos-rebuild switch";
	gc = "sudo nix-collect-garbage --delete-older-than 30d";
      };
      history = {
        size = 10000;
        path = "/home/ezri/.zsh_history";
      };
    };
    programs.starship.enable = true;

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        gruvbox-material
        mini-nvim
        catppuccin-nvim
      ];
      extraConfig = ''
syntax on
set number
set relativenumber
set nocompatible
filetype plugin indent on
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType nix setlocal ts=2 sts=2 sw=2 expandtab
set mouse=
      '';
    };

    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      historyLimit = 100000;
      plugins = with pkgs;
        [
          tmuxPlugins.catppuccin
          tmuxPlugins.yank
          tmuxPlugins.sensible
        ];
      extraConfig = ''
        set -g allow-rename off
        set-option -g status-position top
        set-option -g repeat-time 0
        set-option -g renumber-windows on
        set -sg escape-time 0
        set -g mouse on
        setw -g mode-keys vi
      '';
    };

    programs.git = {
      enable = true;
      userEmail = "me@ezrizhu.com";
      userName = "Ezri Zhu";
     # signing = {
     #   signByDefault = true;
     # 	key = "/home/ezri/.ssh/id_ed25519";
     # };
    };

    home.stateVersion = "24.05";
  };
}
