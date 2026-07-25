# typed: strict
# frozen_string_literal: true

require "download_strategy"
require "utils/github"

# Downloads private GitHub release assets with the user's Homebrew API token.
class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  URL_PATTERN = %r{\Ahttps://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(.+)\z}

  def initialize(url, name, version, **meta)
    match = URL_PATTERN.match(url)
    raise CurlDownloadStrategyError, "Invalid GitHub release URL: #{url}" if match.nil?

    @owner, @repo, @tag, @filename = match.captures
    token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)
    if token.blank?
      raise CurlDownloadStrategyError, <<~EOS
        HOMEBREW_GITHUB_API_TOKEN is required to download claustro.
        Use a GitHub token with read-only Contents access to uniforgeai/claustro.
      EOS
    end

    asset = GitHub.get_release(@owner, @repo, @tag)
                  .fetch("assets")
                  .find { |candidate| candidate["name"] == @filename }
    raise CurlDownloadStrategyError, "Release asset not found: #{@filename}" if asset.nil?

    meta[:headers] = Array(meta[:headers])
    meta[:headers] << "Accept: application/octet-stream"
    meta[:headers] << "Authorization: Bearer #{token}"
    asset_url = "https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset.fetch("id")}"
    super(asset_url, name, version, **meta)
  rescue GitHub::API::Error => e
    raise CurlDownloadStrategyError, <<~EOS
      Unable to access #{@owner}/#{@repo} release #{@tag}.
      Check that HOMEBREW_GITHUB_API_TOKEN has read-only Contents access.
      GitHub API error: #{e.class}
    EOS
  end

  def resolved_basename
    @filename
  end
end
