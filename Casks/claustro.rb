require_relative "../lib/private_github_release_download_strategy"
require "securerandom"

cask "claustro" do
  version "0.17.3"
  arch arm: "arm64", intel: "amd64"
  on_arm do
    sha256 "be9fe2a610fb3972283b53bfb3c959c5d0a2a52a5c9913eb1cd77bc76f02bd67"
  end
  on_intel do
    sha256 "573edba63272466aac1990b4ffc69afe15a55b3c8a14423d3b47ae0715e66a97"
  end
  url "https://github.com/uniforgeai/claustro/releases/download/v0.17.3/claustro_#{version}_darwin_#{arch}.zip",
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
