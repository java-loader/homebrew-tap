# The Homebrew formula, as the release workflow renders it into
# java-loader/homebrew-tap: 0.9.1 and 04c6c5bd2d59d6d34a83c01e86d42d966e79e430c4949c02fa96a56a5e78f26b are filled in from the
# release. It lives here, not in the tap, because it calls the binary's hidden
# install verb, whose arguments change with the binary.
class Jlo < Formula
  desc "Install and switch Eclipse Temurin JDKs by major version"
  homepage "https://github.com/java-loader/jlo"
  url "https://github.com/java-loader/jlo/releases/download/jlo-bin-v0.9.1/jlo-macos-arm64.tar.gz"
  # Spelled out: brew would read "64" from the file name.
  version "0.9.1"
  sha256 "04c6c5bd2d59d6d34a83c01e86d42d966e79e430c4949c02fa96a56a5e78f26b"
  license "MIT"

  depends_on arch: :arm64
  depends_on :macos

  def install
    libexec.install "jlo-bin"
    bin.install_symlink libexec/"jlo-bin" => "jlo"
    # The shell files, with the opt path baked in: it survives upgrades,
    # where the versioned keg does not.
    system libexec/"jlo-bin", "__install", "--keg", pkgshare, "--binary", opt_libexec/"jlo-bin"
    # jlo supports bash and zsh only; the default list includes fish.
    generate_completions_from_executable(libexec/"jlo-bin", "completions", shells: [:bash, :zsh])
  end

  def caveats
    <<~EOS
      To use J'Lo, add these lines to ~/.zshrc (bash: ~/.bash_profile):

      [ -s #{opt_pkgshare}/jlo.sh ] && . #{opt_pkgshare}/jlo.sh
      [ -s #{opt_pkgshare}/autoload.sh ] && . #{opt_pkgshare}/autoload.sh

      The second is optional: it switches JDK on cd. Then open a new shell.
      A login bash (what macOS terminals start) skips ~/.bashrc and reads
      only the first of ~/.bash_profile, ~/.bash_login, ~/.profile that
      exists - put the lines there.

      Tab completion comes from Homebrew's shell completion setup.

      Installed J'Lo with its installer before? Remove ~/.jlo/bin, ~/.jlo/*.sh
      and ~/.local/bin/jlo, and the profile lines naming ~/.jlo; keep
      ~/.jlo/default.jlorc. After `brew uninstall jlo` the lines above do
      nothing, and ~/.jlo keeps your default.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jlo --version")
  end
end
