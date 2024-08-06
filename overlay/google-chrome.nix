self: super: {
  google-chrome = super.google-chrome.override ({
    commandLineArgs = "--gtk-version=4";
  });
}
