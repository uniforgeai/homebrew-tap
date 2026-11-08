require_relative "../lib/private_github_release_download_strategy"

cask "claustro" do
  version "0.18.0"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "3f994e34275ab1ebee8ae88f840161edf71856e22ac83d2736f4f8d68d9156e8"
  end
  on_intel do
    sha256 "b09998a3d4a3b850bb1b5302cadd5f58b52730071382be1cf3ab11c5412b7e4c"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.18.0/claustro_#{version}_darwin_#{arch}.zip",
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
