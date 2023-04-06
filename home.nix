{ config, pkgs, inputs, userName, ... }: let
  nixpkgsStable = import inputs.nixpkgsStable { system = "x86_64-linux"; };
in {
  nix = {
    settings = {
      experimental-features = "nix-command flakes repl-flake";
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = userName;
  home.homeDirectory = "/home/${userName}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  home.sessionVariables = {
    BROWSER = "microsoft-edge";
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellOptions = [
       "histappend" "checkwinsize" "extglob" "globstar" "checkjobs" "-cdspell"
    ];
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      nv = "nvim";
    };
    # historyControl = [ "ignoredups" "ignorespace" ];
    historyFileSize = 100000;
    historySize = 10000;
    /* bashrcExtra = ''
      PS1='\[\033[01;34m\]\W \[\033[00m\]\$ '
      set -o vi
      HISTCONTROL=ignoreboth
    ''; */
    bashrcExtra = ''
      if [ -z "''${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
      fi

      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \$\[\033[00m\] '
      set -o vi
      HISTCONTROL=ignoreboth
    '';
  };
  programs.readline = {
    enable = true;
    extraConfig = "set completion-ignore-case On";
  };
  # targets.genericLinux.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # programs.ssh = {
  #   enable = true;
  #   extraConfig = '' 
  #     AddKeysToAgent yes
  #   '';
  # };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
  # home.packages = (with pkgs; [
    # vscode-fhs
    nixpkgsStable.libreoffice
    spotify
    nix-prefetch-git
    cabal2nix
    curl
    neofetch
    freshfetch
    ripgrep
    wget
    xclip
    nodejs
    firefox
    dmidecode
    libchewing
    microsoft-edge
    gcc_multi gccMultiStdenv 
    rustup openssh ssh-copy-id gh 
    cabal-install haskell.compiler.ghc944 ghcid
    (haskell-language-server.override { supportedGhcVersions = ["944"]; })
    nil
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  dconf.settings = {
    "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;
    "org/gnome/desktop/peripherals/touchpad".disable-while-typing = true;
    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = ["microsoft-edge.desktop" "firefox.desktop;"];
      "application/xhtml+xml" = ["microsoft-edge.desktop" "firefox.desktop;"];
      "text/html" = ["microsoft-edge.desktop" "firefox.desktop;"];
      "x-scheme-handler/https" = ["microsoft-edge.desktop" "firefox.desktop;"];
      "x-scheme-handler/about" = ["microsoft-edge.desktop" "firefox.desktop;"];
      "x-scheme-handler/unknown" = ["microsoft-edge.desktop"];
    };
    associations.added = {
      "x-scheme-handler/http"  =  ["microsoft-edge.desktop" "firefox.desktop;"];
      "application/xhtml+xml" = ["microsoft-edge.desktop" "firefox.desktop;"];
      "text/html" = ["microsoft-edge.desktop" "firefox.desktop;"];
      "x-scheme-handler/https" = ["microsoft-edge.desktop" "firefox.desktop;"];
    };
  };

  # home.file = {
  #   "\.haskeline".source = programs/haskell/.haskeline;
  #   "\.ghci".source = programs/haskell/.ghci;
  #   "\.cabal" = {
  #     recursive = true;
  #     source = programs/cabal/.cabal;
  #   };
  #   "\.bashrc".source = programs/bash/.bashrc;
  #   "\.bash_aliases".source = programs/bash/.bash_aliases;
  #   "\.profile".source = programs/bash/.profile;
  #   "\.bash_logout".source = programs/bash/.bash_logout;
  # };


  programs.neovim = {
    enable = true;
    plugins = ( with pkgs.vimPlugins; [
      smart-splits-nvim
      dracula-vim
      tokyonight-nvim
      popup-nvim
      gruvbox-nvim
      plenary-nvim
      comment-nvim
      nvim-web-devicons
      nvim-tree-lua
      bufferline-nvim
      vim-bbye
      lualine-nvim
      toggleterm-nvim
      nvim-cmp
      cmp-nvim-lua
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp_luasnip
      luasnip
      friendly-snippets
      nvim-lspconfig
      telescope-nvim
      playground
      nvim-ts-rainbow
      smart-splits-nvim
      ( nvim-treesitter.withPlugins (plugins: with pkgs.tree-sitter-grammars; [
        tree-sitter-c
        tree-sitter-haskell
        tree-sitter-nix
        tree-sitter-lua
        tree-sitter-rust
      ] ) )
    ] );
    extraPackages = ( with pkgs; [
      rnix-lsp
      fd
    ] );
    extraConfig = "luafile $HOME/.config/nvim/init_lua.lua";
  };
  xdg.configFile.nvim = {
    recursive = true;
    source = ./programs/nvim;
  };

  programs.git = {
    enable = true;
    userName = "alex800121";
    userEmail = "alex800121@hotmail.com";
  };
  
  # programs.gh = {
  #   enable = true;
  #   enableGitCredentialHelper = true;
  #   settings = {
  #     git_protocol = "ssh";
  #     prompt = "enabled";
  #     aliases = {
  #       co = "pr checkout";
  #     };
  #     editor = "nvim";
  #   };
  # };
  
  programs.htop.enable = true;

  programs.helix = {
    enable = true;
    settings = {
      theme = "dark_plus";
      editor = {
        line-number = "relative";
        bufferline = "multiple";
      };
      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      editor.file-picker = {
        hidden = false;
        parents = false;
        # ignore = false;
        git-ignore = false;
        # git-global = false;
        # git-exclude = false;
      };
      keys.normal = {
        space.w = ":w";
        space.q = ":q";
        space.x = ":bc";
        L = "goto_next_buffer";
        H = "goto_previous_buffer";
      };
    };
    languages = [
      {
        name = "haskell";
      }
    ];
  };

  programs.alacritty = {
    enable = true;
    # package = pkgs.alacritty;
  };
  xdg.configFile."alacritty" = {
    # recursive = true;
    source = programs/alacritty;
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
    ];
    terminal = "screen-256color";
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 10000;
    prefix = "C-a";
    shortcut = "a";
    escapeTime = 0;
    extraConfig = ''
      # reload config without killing server
      # bind r source-file ~/.tmux.conf \; display-message "Config reloaded..."

      # "|" splits the current window vertically, and "-" splits it horizontally
      unbind '"'
      unbind %
      bind l split-window -h -c "#{pane_current_path}"
      bind h split-window -h -c "#{pane_current_path}"
      bind j split-window -v -c "#{pane_current_path}"
      bind k split-window -v -c "#{pane_current_path}"

      # Pane navigation (vim-like)
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # Pane resizing
      bind -n C-h resize-pane -L 2
      bind -n C-j resize-pane -D 1
      bind -n C-k resize-pane -U 1
      bind -n C-l resize-pane -R 2

      ### other optimization
      # set the shell you like (zsh, "which zsh" to find the path)
      # set -g default-command /bin/zsh
      # set -g default-shell /bin/zsh

      # mouse is great!
      set-option -g mouse on

      # stop auto renaming
      setw -g automatic-rename off
      set-option -g allow-rename off

      # renumber windows sequentially after closing
      set -g renumber-windows on

      # window notifications; display activity on other window
      setw -g monitor-activity on
      set -g visual-activity on
    '';
  };

  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = true;
    enableUpdateCheck = true;
    mutableExtensionsDir = true;
  };
}
