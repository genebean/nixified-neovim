# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{inputs}: final: prev:
with final.pkgs.lib; let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    # plugins from nixpkgs go in here.
    # https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=vimPlugins
    
    lazy-nvim # Plugin manager... but plugins should all be here. It is really just for lazy loading and so that snippets of lua don't have to be reformmated to work with Nix

    # Plugin list
    alpha-nvim
    bufferline-nvim
    catppuccin-nvim
    nvim-cmp                 # https://github.com/hrsh7th/nvim-cmp
    cmp-nvim-lsp             # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp/
    luasnip                  # snippets | https://github.com/l3mon4d3/luasnip/
    edgy-nvim
    mason-nvim
    mason-lspconfig-nvim
    lualine-nvim             # Status line | https://github.com/nvim-lualine/lualine.nvim/
    neo-tree-nvim
    noice-nvim
    (mkNvimPlugin inputs.mason-null-ls "mason-null-ls")
    none-ls-nvim
    telescope-nvim
    telescope-cheat-nvim
    telescope-symbols-nvim
    telescope-ui-select-nvim
    todo-comments-nvim
    toggleterm-nvim
    nvim-treesitter.withAllGrammars
    trouble-nvim
    vim-tmux-navigator
    which-key-nvim
    
    # Deps
    nvim-web-devicons
    nui-nvim
    plenary-nvim

  ];

  extraPackages = with pkgs; [
    gcc    # needed so treesitter can do compiling
    sqlite # needed by sqlite.lua used by telescope-cheat

    # language servers, etc.
    lemminx             # XML LSP
    lua-language-server # lua LSP
    nil                 # nix LSP
    #puppet-editor-services 
    ruff-lsp            # Python LSP

    prettier-d-slim     # formatter for HTML, JS, JSON, etc.
    stylua              # formatter for lua
    puppet-lint         # linter for puppet
    rubocop             # ruby linter
  ];
in {
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
