#!/usr/bin/env bash
set -euo pipefail

VERSION=$1
SHA256=$2
URL=${3:-https://github.com/veelenga/mantis-shrimp/archive/refs/tags/v$VERSION.tar.gz}

cat <<FORMULA
class MantisShrimp < Formula
  desc "Menu bar app that watches your posture through the Mac camera"
  homepage "https://github.com/veelenga/mantis-shrimp"
  url "$URL"
  version "$VERSION"
  sha256 "$SHA256"
  head "https://github.com/veelenga/mantis-shrimp.git", branch: "main"

  depends_on macos: :sonoma

  def install
    ENV["VERSION"] = version.to_s
    ENV["SWIFT_BUILD_FLAGS"] = "--disable-sandbox"
    system "scripts/bundle.sh"
    prefix.install "build/MantisShrimp.app"
  end

  def caveats
    <<~EOS
      Link the app into your Applications folder:
        ln -sf #{opt_prefix}/MantisShrimp.app ~/Applications/

      The app is signed ad hoc, so macOS asks for camera access again after each update.
    EOS
  end

  test do
    assert_path_exists prefix/"MantisShrimp.app/Contents/MacOS/MantisShrimp"
  end
end
FORMULA
