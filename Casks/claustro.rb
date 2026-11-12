require_relative "../lib/private_github_release_download_strategy"

cask "claustro" do
  version "0.19.0"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "9979a14def11a7e385ae3325f47d69eb0249ab0e112787c1f681b5a4ef7b77f1"
  end
  on_intel do
    sha256 "b71e9a627c9f80a524cfcd9a5d4386dc79dbedc02e76c41faa20cb1b948205e1"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.19.0/claustro_#{version}_darwin_#{arch}.zip",
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
