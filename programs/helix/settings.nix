{
  theme = "dark_plus";
  editor = {
    line-number = "relative";
    bufferline = "always";
    mouse = true;
    auto-format = true;
    auto-completion = true;
    completion-trigger-len = 1;
  };
  editor.file-picker = {
    hidden = false;
    parents = false;
    git-ignore = false;
  };
  editor.soft-wrap = {
    enable = true;
  };
  editor.cursor-shape = {
    insert = "bar";
    normal = "block";
    select = "underline";
  };
  keys.normal = {
    space.e = "file_picker";
    space.w = ":w";
    space.q = ":q";
    space.x = ":bc";
    L = ":bn";
    H = ":bp";
  };
}