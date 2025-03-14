# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  users.users.ezri = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "docker" "libvirtd" ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.kde-pim.kmail = true;

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
        zathura
        feh
        file
        docker-compose
        lm_sensors
        xdg-utils
        kdePackages.kconfig
        kdePackages.kmail
        kdePackages.kmail-account-wizard
        kdePackages.kleopatra
        kdePackages.kcmutils
        openssl
        bat
        restic
        rclone
        age
        ripgrep
        eza
        pciutils
        whois
        zip
        unzip
        slack
        typst
        man-pages-posix
        man-pages
        usbutils
        imagemagick
        telegram-desktop
        magic-wormhole
        libnotify
      	wl-clipboard
        p7zip
        ungoogled-chromium
        spicetify-cli
        obsidian
        code-cursor
        nicotine-plus
        picard
        discord
        (pkgs.discord-canary.overrideAttrs (old: {
  postInstall = old.postInstall + ''
    mv $out/opt/DiscordCanary/resources/app.asar $out/opt/DiscordCanary/resources/_app.asar
    mkdir -p $out/opt/DiscordCanary/resources/app/app_bootstrap
    cat > $out/opt/DiscordCanary/resources/app/app_bootstrap/index.js <<- EOF
    const path = require("path")
    require(path.resolve(process.env.HOME, "hh3/lib/injector.js"))
      .inject(path.resolve(__dirname, "../../../_app.asar"))
    require("../../_app.asar")
    process.mainModule = require.cache[require.resolve("../../_app.asar")]
    EOF
    cat > $out/opt/DiscordCanary/resources/app/package.json <<- EOF
    { "name": "discord", "main": "./app_bootstrap/index.js", "private": true }
    EOF
  '';
}))
    ];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vagrant"
      "slack"
      "discord"
      "discord-canary"
      "obsidian"
      "cursor"
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
          vim-go
          coc-rust-analyzer
          coc-nvim
          gleam-vim
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
      plugins = with pkgs.tmuxPlugins;
      [
      catppuccin
          yank
          sensible
          pain-control
          battery
      ];
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

        set -g @catppuccin_window_left_separator ""
        set -g @catppuccin_window_right_separator " "
        set -g @catppuccin_window_middle_separator " █"
        set -g @catppuccin_window_number_position "right"

        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_default_text "#W"

        set -g @catppuccin_window_current_fill "number"
        set -g @catppuccin_window_current_text "#W"

        set -g @catppuccin_status_modules_right "session user host battery date_time"
        set -g @catppuccin_status_left_separator  " "
        set -g @catppuccin_status_right_separator ""
        set -g @catppuccin_status_fill "icon"
        set -g @catppuccin_status_connect_separator "no"

        set -g @catppuccin_directory_text "#{pane_current_path}"
        set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M"
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
