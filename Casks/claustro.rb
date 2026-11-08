require_relative "../lib/private_github_release_download_strategy"

cask "claustro" do
  version "0.18.1"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "f7fd8f36558f54e08e3625c7a944694c64aa4ea83ded58f876790af1f3ddf401"
  end
  on_intel do
    sha256 "775b026410b838ddf74d290f9f26fc524fcc3dfb26f8840a4f7f98ba6ecd001f"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.18.1/claustro_#{version}_darwin_#{arch}.zip",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  name "Claustro"
  desc "Disposable Docker sandboxes with T3 and direct ACP"
  homepage "https://github.com/uniforgeai/claustro"
  depends_on macos: ">= :ventura"

  preflight do
    executable = "#{staged_path}/claustro"
    if File.executable?(executable)
      system_command executable, args: ["update", "--check-prepared"], sudo: false, must_succeed: true
    end
  end

  binary "claustro"
  binary "claustrod"

  uninstall_preflight do
    executable = "#{staged_path}/claustro"
    if File.executable?(executable)
      system_command executable,
                     args: ["update", "--check-prepared"],
                     sudo: false, must_succeed: true
    end
  end

  caveats <<~EOS
    Finish active work and stop claustrod before claustro update or uninstall.
    Legacy services must be stopped with the original CLI or service manager. User data and sandboxes are kept.
  EOS
end
