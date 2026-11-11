require_relative "../lib/private_github_release_download_strategy"

cask "claustro" do
  version "0.18.3"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "57835d1ae5e8694a103956d668cb7b6dd53ed25757000a782e3d7f6b2b33a676"
  end
  on_intel do
    sha256 "32c45a43b36645e6bebc00d9431b0faaf71d0d96453f4834a7d34374d6263e0a"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.18.3/claustro_#{version}_darwin_#{arch}.zip",
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
