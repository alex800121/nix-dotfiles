[
  {
    name = "haskell";
    auto-format = true;
    config = {
      haskell.formattingProvider = "ormolu";
      haskell.plugin.rename.config.diff = true;
    };
    # formatter = { command = "ormolu"; };
  }
  {
    name = "nix";
  }
]