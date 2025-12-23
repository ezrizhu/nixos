{ config, lib, pkgs, ... }:

{
  users.users.ezri = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "docker"];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  home-manager.users.ezri = { pkgs, ... }: {
    home.packages = with pkgs; [
      croc
        tree
        hyfetch
        htop
        sdrpp
        dig
        mtr
        aerc
        wget
        curl
        signal-desktop
        zathura
        feh
        file
        docker-compose
        lm_sensors
        xdg-utils
        openssl
        bat
        age
        ripgrep
        eza
        whois
        zip
        unzip
        man-pages-posix
        man-pages
        usbutils
        imagemagick
        magic-wormhole
        libnotify
        p7zip
        obsidian
        discord
    ];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "discord"
      "obsidian"
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
        ls = "eza -lah";
        cat = "bat -Pp";
        catt = "cat";
        cata = "bat -APp";
        update = "sudo nix-channel --update";
        upgrade = "sudo nixos-rebuild switch";
        cg = "sudo nix-collect-garbage";
        cgd = "sudo nix-collect-garbage --delete-older-than 7d";
        userConfig = "vim /etc/nixos/ezri.nix";
        sysConfig = "vim /etc/nixos/configuration.nix";
        tmuxn = "tmux new-session 'tmux source-file .config/tmux/tmux.conf && zsh'";
        nsz = "nix-shell --run zsh";
        cm = "cargo mommy";
      };
      history = {
        size = 10000;
        path = "/home/ezri/.zsh_history";
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        aws.disabled = true;
        add_newline = false;
        character = {
          success_symbol = "[λ](bold green)";
          error_symbol = "[λ](bold red)";
        };
      };
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
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
        set mouse=
        set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
        autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
        autocmd FileType nix setlocal ts=2 sts=2 sw=2 expandtab
        set colorcolumn=80
        set textwidth=80
        cmap w!! w !sudo tee % >/dev/null
        set termguicolors
        colorscheme catppuccin-mocha
        '';
    };

    programs.tmux = {
        enable = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "tmux-256color";
        historyLimit = 100000;
        plugins = with pkgs.tmuxPlugins; [ catppuccin yank sensible pain-control ];
        extraConfig = ''
          set -g allow-rename off
          set-option -g status-position top
          set-option -g repeat-time 0
          set-option -g renumber-windows on
          set -sg escape-time 0
    
          set -s set-clipboard on
          set -g mouse on
          setw -g mode-keys vi
          set-option -g mode-keys vi
          set-option -ga terminal-overrides ",xterm-256color*:Tc:smso"
    
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
        '';
      };

    programs.git = {
      enable = true;
      userEmail = "me@ezrizhu.com";
      userName = "Ezri Zhu";
      signing = {
        signByDefault = true;
        key = "/home/ezri/.ssh/id_ed25519";
      };
      extraConfig = {
        gpg = {
          "format" = "ssh";
        };
      };
    };


    home.stateVersion = "24.05";
  };
}
