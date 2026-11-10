require_relative "../lib/private_github_release_download_strategy"

cask "claustro" do
  version "0.18.2"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "d21b6507f6e4ad6e4679032f0bc02ff4928d7687f1e77c429753c994ebaf3fed"
  end
  on_intel do
    sha256 "629c6d5a09dab194d9b96b722fcc3d04eba7ce672072c0f96c53739c63aeafaf"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.18.2/claustro_#{version}_darwin_#{arch}.zip",
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
