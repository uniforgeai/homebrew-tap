require_relative "../lib/private_github_release_download_strategy"

cask "claustro" do
  version "0.19.1"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "0384af785927c72e7bdbdbe082b1234a19df13bc568a50dd91aa79c7d0561d10"
  end
  on_intel do
    sha256 "f22d9afeb41fb16a06d030261d6f3f72caa4b57905c3f5a20d1227213fe54e51"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.19.1/claustro_#{version}_darwin_#{arch}.zip",
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
