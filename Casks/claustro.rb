require_relative "../lib/private_github_release_download_strategy"
require "securerandom"

cask "claustro" do
  version "0.17.6"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "8fc354bfb0daefaa18e9274779fc83127a96f58699bd1b22742f963e7bcaf835"
  end
  on_intel do
    sha256 "e6033e8c5cded091d2416c1b5bf156ffadc1c2fab89d954990602061e3b16a72"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.17.6/claustro_#{version}_darwin_#{arch}.zip",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  name "Claustro"
  desc "Persistent coding threads in disposable Docker sandboxes"
  homepage "https://github.com/uniforgeai/claustro"
  depends_on macos: ">= :ventura"

  preflight do
    executable = "#{HOMEBREW_PREFIX}/bin/claustro"
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
                     args: ["host", "unregister", "--operation-id", "bundle-uninstall_#{SecureRandom.hex(12)}"],
                     sudo: false, must_succeed: true
    end
  end

  caveats <<~EOS
    Use claustro update for coordinated local updates. Remote hosts update explicitly and separately.
    Uninstall stops and unregisters the per-user service and retains state, drafts and sandboxes.
  EOS
end
