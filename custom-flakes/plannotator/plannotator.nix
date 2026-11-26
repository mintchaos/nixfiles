{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  glibc,
  git,
  xdg-utils,
  version,
  hash,
}:

stdenv.mkDerivation {
  pname = "plannotator";
  inherit version;

  src = fetchurl {
    url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-linux-x64.tar.xz";
    inherit hash;
  };

  sourceRoot = ".";
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ glibc ];

  # Bun's compiled executable contains the application payload; do not strip it.
  dontStrip = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 plannotator-linux-x64 "$out/libexec/plannotator"
    makeWrapper "$out/libexec/plannotator" "$out/bin/plannotator" \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          xdg-utils
        ]
      } \
      --set PLANNOTATOR_AUTO_UPDATE 0 \
      --set PLANNOTATOR_UPDATE_CHECK 0 \
      --run 'case "''${1-}" in update|uninstall) echo "Plannotator is managed by Nix; update or remove it through your Nix configuration." >&2; exit 1;; esac'
    runHook postInstall
  '';

  meta = {
    description = "Browser-based plan annotation and code review for coding agents";
    homepage = "https://plannotator.ai";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "plannotator";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
