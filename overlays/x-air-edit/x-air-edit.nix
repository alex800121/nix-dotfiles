{ makeDesktopItem, stdenv, fetchurl, lib, curlWithGnuTls, libGL, libX11, libXext, alsa-lib, freetype, ... }: let
  brand = "Behringer";
  type = "X-AIR";
  version = "1.8";
  url = "https://mediadl.musictribe.com/download/software/behringer/XAIR/X-AIR-Edit_LINUX_1.8.tar.gz";
  sha256 = "sha256-GwTZbTCZmriAygdmuCDcxeXssFpWsj4L6yNo/OFQGH0=";
  homepage = "https://www.behringer.com/product.html?modelCode=P0BI8";
  pname = "${type}-Edit";
  libPath = lib.makeLibraryPath [
    curlWithGnuTls
    libGL
    libX11           # libX11.so.6
    libXext          # libXext.so.6
    alsa-lib          # libasound.so.2
    freetype         # libfreetype.so.6
    stdenv.cc.cc.lib # libstdc++.so.6
  ];
  meta = with lib; {
    inherit homepage;
    description = "Editor for the ${brand} ${type} digital mixer";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ maintainers.magnetophon ];
  };
in stdenv.mkDerivation {
  inherit meta pname version;
  src = fetchurl {
    inherit url;
    inherit sha256;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontStrip = true;

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "X-AIR-Edit -d";
    icon = pname;
    desktopName = "X Air Edit";
    comment = meta.description;
    categories = [ "Audio" ];
  };

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin
    mkdir -p $out/share/pixmaps
    mkdir -p $out/share/applications
    cp ${pname}_icon.png $out/share/pixmaps/${pname}.png
    install -D -t $out/share/applications $desktopItem/share/applications/*
  '';

  preFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/${pname}
  '';
}
