{ config, lib, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
  ];
  users.users.ezri = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "plugdev" "dialout" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    home = "/ezri";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.niri.enable = true;

  home-manager.users.ezri = { pkgs, ... }: {
    imports = [
      <impermanence/home-manager.nix>
    ];
    home.persistence."/persist/ezri" = {
      directories = [
        ".kube"
        ".ssh"
        ".mozilla"
        ".cache"
        ".gnupg"
        ".config/obsidian"
        ".config/aerc"
        ".config/Signal"
        ".config/waybar"
        ".config/discord"
        ".local/share/zsh"
        ".local/share/mine"
        "Documents/"
        {
          directory = ".nix-search";
          method = "symlink";
        }
      ];
      files = [
        ".config/niri/config.kdl"
        ".config/htop/htoprc"
        ".config/hyfetch.json"
      ];
      allowOther = true;
    };
    home.packages = with pkgs; [
        brightnessctl
        wdisplays
        acpi
        xwayland-satellite
        swaybg
        obsidian
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
        lm_sensors
        xdg-utils
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
        man-pages-posix
        man-pages
        usbutils
        magic-wormhole
        libnotify
        wl-clipboard
        p7zip
        ungoogled-chromium
        dissent
        networkmanagerapplet
        blueman
        nautilus
        tarsnap
        cardpeek
        (pkgs.writeShellScriptBin "nix-search" ''
           export NIX_SEARCH_INDEX_PATH=$HOME/.nix-search
           exec ${lib.getExe pkgs.nix-search} "$@"
        '')
        (pkgs.discord.override { withMoonlight = true; })
    ];

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Breeze-dark";
        package = pkgs.gnome-themes-extra;
      };
    };

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "obsidian"
      "discord"
      "tarsnap"
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
        path = "/ezri/.local/share/zsh/.zsh_history";
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

set -g @catppuccin_flavor "mocha"
set -g @catppuccin_window_status_style "rounded"

set -g status-right-length 100
set -g status-left-length 100
set -g status-left ""
set -g status-right "#{E:@catppuccin_status_session}"
set -ag status-right "#{E:@catppuccin_status_date_time}"
set -ag status-right "#{E:@catppuccin_status_host}"
set -ag status-right "#{E:@catppuccin_status_user}"
set -ag status-right "#{E:@catppuccin_status_application}"
set -ag status-right "#{E:@catppuccin_status_directory}"
set -g @catppuccin_window_text " #W "
set -g @catppuccin_window_current_text " #W "

set-option -g bell-action any
set-option -g visual-bell off
set-hook -g alert-bell "run-shell '~/.config/tmux/bell.sh \"#S\" \"#W\"'"
        '';
    };

    programs.waybar = {
      enable = true;
    };

    programs.alacritty = {
      enable = true;
      settings = {
        window.decorations = "None";
        font = {
          size = 10;
          normal = {
            family = "Fira Code";
            style = "Regular";
          };
        };
      };
    };

    programs.git = {
      enable = true;
      userEmail = "me@ezrizhu.com";
      userName = "Ezri Zhu";
      signing = {
        signByDefault = true;
        key = "/ezri/.ssh/id_ed25519";
      };
      extraConfig = {
        gpg = {
          "format" = "ssh";
        };
        safe = {
          "directory" = "*";
        };
      };
    };

    home.stateVersion = "24.05";
  };
}

