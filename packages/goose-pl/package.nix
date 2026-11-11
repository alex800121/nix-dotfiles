{
  stdenv,
  lib,
  git,
  fetchFromGitHub,
  cmake,
  ninja,
  makeWrapper,
  glibc,
}:
stdenv.mkDerivation {
  pname = "goose";
  version = "v2026.4";

  src = fetchFromGitHub {
    repo = "goose";
    owner = "aardappel";
    rev = "v2026.4";
    hash = "sha256-EeTrRrECNyExsU8+dAh9JexQGnMOhgeuu8UoOD78wKw=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    makeWrapper
  ];

  cmakeFlags = [
    "-DGOOSE_BUILTIN_LIBS="
    "-DGOOSE_TCC_LIB_PATH=${placeholder "out"}/share/goose/tcclib"
    "-DGOOSE_TCC_SYSINCLUDEPATHS={B}/include:${glibc.dev}/include"
    "-DGOOSE_TCC_LIBPATHS={B}:${glibc}/lib"
  ];

  installPhase = ''
    runHook preInstall

    # Already inside the CMake build directory.
    install -Dm755 goose "$out/bin/goose"

    mkdir -p "$out/share/goose"

    # The standard library is in the source directory.
    cp -r ../stdlib "$out/share/goose/stdlib"

    # TinyCC runtime is generated in the build directory.
    cp -r tcclib "$out/share/goose/tcclib"

    wrapProgram "$out/bin/goose" \
      --set-default GOOSE_STDLIB \
        "$out/share/goose/stdlib" \
      --set-default GOOSE_TCCLIB \
        "$out/share/goose/tcclib" \
      --prefix PATH : \
        "${
          lib.makeBinPath ([
            stdenv.cc
            cmake
            git
          ])
        }"

    runHook postInstall
  '';

  meta = {
    description = "Goose programming language";
    homepage = "https://github.com/aardappel/goose";
    license = lib.licenses.asl20;
    mainProgram = "goose";
  };
}
