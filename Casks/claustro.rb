require_relative "../lib/private_github_release_download_strategy"
require "securerandom"

cask "claustro" do
  version "0.16.9"
  sha256 "88dfa616daf91daf13a9bd512b43b88af25aa745bf5eda1ef4124e6dbab6c1e0"
  url "https://github.com/uniforgeai/claustro/releases/download/v0.16.9/claustro_companion_0.16.9_darwin_arm64.zip", using: GitHubPrivateRepositoryReleaseDownloadStrategy
  name "Claustro"
  desc "Persistent coding threads in disposable Docker sandboxes"
  homepage "https://github.com/uniforgeai/claustro"
  depends_on arch: :arm64
  depends_on macos: ">= :ventura"

  preflight do
    executable = "#{appdir}/ClaustroCompanion.app/Contents/MacOS/claustro"
    executable = "#{HOMEBREW_PREFIX}/bin/claustro" unless File.executable?(executable)
    if File.executable?(executable)
      system_command executable, args: ["update", "--check-prepared"], sudo: false, must_succeed: true
    end
  end

  app "ClaustroCompanion.app"
  binary "#{appdir}/ClaustroCompanion.app/Contents/MacOS/claustro"
  binary "#{appdir}/ClaustroCompanion.app/Contents/MacOS/claustrod"

  uninstall_preflight do
    executable = "#{appdir}/ClaustroCompanion.app/Contents/MacOS/claustro"
    if File.executable?(executable)
      system_command executable,
                     args: ["host", "unregister", "--operation-id", "bundle-uninstall_#{SecureRandom.hex(12)}"],
                     sudo: false, must_succeed: true
    end
  end

  caveats <<~EOS
    Claustro uses ad hoc execution signatures and is not notarized.
    If macOS blocks first launch, approve Claustro in System Settings > Privacy & Security > Open Anyway,
    then open the app again. App launch at login is off by default.
    Use claustro update for coordinated local updates. Remote hosts update explicitly and separately.
    Uninstall stops and unregisters the per-user service and retains state, drafts and sandboxes.
  EOS
end
