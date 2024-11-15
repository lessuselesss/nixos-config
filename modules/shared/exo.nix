{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "exo";
  version = "1.0.0"; # Replace with the actual version

  src = pkgs.fetchFromGitHub {
    owner = "exo-explore";
    repo = "exo";
    rev = "main"; # or a specific commit hash
    sha256 = "sha256-WrJrhMtq+S5VD3oyW1k3fkOHunTzdFk0HavjOXLhIKU="; # Replace with the actual hash
  };

  buildInputs = [
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.python311Packages.setuptools
    pkgs.git
    # Add other dependencies as needed
  ];

  installPhase = ''
    mkdir -p $out/bin
    pip install --prefix=$out .
  '';

  meta = with pkgs.lib; {
    description = "Run your own AI cluster at home with everyday devices";
    homepage = "https://github.com/exo-explore/exo";
    license = licenses.gpl3Plus; # Adjust based on the actual license
    maintainers = with maintainers; [ yourName ]; # Replace with your name
  };
}