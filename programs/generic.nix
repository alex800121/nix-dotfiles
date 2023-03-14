# { callPackage, stdenv, fetchurl, lib, curlWithGnuTls, libGL, libX11, libXext, alsa-lib, freetype, brand, type, version, homepage, url, sha256, ... }:
{ callPackage, stdenv, fetchurl, lib, curlWithGnuTls, libGL, libX11, libXext, alsa-lib, freetype, ... }:
stdenv.mkDerivation rec {
  brand = "Behringer";
  type = "X-AIR";
  version = "1.7";
  url = "https://mediadl.musictribe.com/download/software/behringer/XAIR/X-AIR-Edit_LINUX_1.7.tar.gz";
  sha256 = "sha256-cuY47ZtTS+dgF02x5Z/X4YUtN1m2XNYEXbh3s7PmFrM=";
  homepage = "https://www.behringer.com/product.html?modelCode=P0BI8";
  pname = "${type}-Edit";
  inherit version;

  src = fetchurl {
    inherit url;
    inherit sha256;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin
  '';
  preFixup = let
    # we prepare our library path in the let clause to avoid it become part of the input of mkDerivation
    libPath = lib.makeLibraryPath [
      curlWithGnuTls
      libGL
      libX11           # libX11.so.6
      libXext          # libXext.so.6
      alsa-lib          # libasound.so.2
      freetype         # libfreetype.so.6
      stdenv.cc.cc.lib # libstdc++.so.6
    ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/${pname}
  '';

  meta = with lib; {
    inherit homepage;
    description = "Editor for the ${brand} ${type} digital mixer";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [ maintainers.magnetophon ];
  };
}
