{ lib, buildNpmPackage, fetchurl, nodejs, runCommand, version }:

let
  tarball = fetchurl {
    url = "https://registry.npmjs.org/@pencil.dev/cli/-/cli-${version}.tgz";
    sha256 = "wdvxGt4fNZBoAbS4XqD3MRJ/RQy2Ug/v0J8c0VL8rXk=";
  };
in
buildNpmPackage {
  pname = "pencil";
  inherit version;

  src = runCommand "pencil-src" { } ''
    mkdir $out
    tar xzf ${tarball} -C $out --strip-components=1
    cp ${./package-lock.json} $out/package-lock.json
  '';

  npmDepsHash = "sha256-VeyCBPxmSSpZ8jj/GWwxU6gyR/O1XgrVpA+7IQN78Qs=";

  npmPackFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/share/doc/pencil
    ln -sf $out/lib/node_modules/@pencil.dev/cli/dist/index.cjs $out/bin/pencil
    cp $out/lib/node_modules/@pencil.dev/cli/SKILL.md $out/share/doc/pencil/SKILL.md
  '';

  meta = with lib; {
    description = "Pencil CLI — AI-powered design in your terminal";
    homepage = "https://pencil.dev";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "pencil";
  };
}
