{ lib, stdenv, fetchurl, alsa-lib, atk, at-spi2-atk, at-spi2-core, cairo, cups, dbus, expat, gtk3, libgbm, nss, pango, udev, libx11, libxcomposite, libxdamage, libxext, libxfixes, libxrandr, libxcb, libxkbcommon, autoPatchelfHook, makeWrapper, copyDesktopItems, makeDesktopItem, version }:

let
  arch = if stdenv.hostPlatform.system == "x86_64-linux" then "x64" else "arm64";
in
stdenv.mkDerivation {
  pname = "pencil-gui";
  inherit version;

  src = fetchurl {
    url = "https://pencil.dev/download/Pencil-linux-${arch}.tar.gz";
    sha256 = "sha256-t+cXG1YMzjw2wpeulaUKEceICVrqZTbGbHfHqBLhPVs=";
  };

  sourceRoot = "Pencil-${version}-linux-${arch}";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gtk3
    libgbm
    nss
    pango
    udev
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxkbcommon
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/pencil-gui $out/bin
    cp -r ./* $out/lib/pencil-gui/
    ln -s $out/lib/pencil-gui/pencil $out/bin/pencil-gui

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "pencil-gui";
      exec = "pencil-gui %U";
      icon = "pencil-gui";
      desktopName = "Pencil";
      comment = "Design on canvas. Land in code.";
      categories = [ "Development" "Graphics" ];
      terminal = false;
      startupWMClass = "Pencil";
    })
  ];

  postFixup = ''
    wrapProgram $out/bin/pencil-gui \
      --prefix LD_LIBRARY_PATH : $out/lib/pencil-gui
  '';

  meta = with lib; {
    description = "Pencil — Design on canvas. Land in code.";
    homepage = "https://pencil.dev";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "pencil-gui";
  };
}
