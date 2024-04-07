require 'net/http'
require 'json'

class ProgressBar
  def initialize(progress = 0, size:, description:)
    @progress = progress
    @size = size
    @description = description
  end

  def report(increment)
    @progress += increment
    "\r#{@description}: #{bar_visualization} #{percent_visualization}"
  end

  private

  def bar_visualization
    steps = 15
    step_share = 1.to_f / steps
    fill = @progress.to_f / @size
    bar = steps.times.map do |i|
      fill > i * step_share ? '█' : ' '
    end.join('')
    "|#{bar}|"
  end

  def percent_visualization
    percent = (@progress.to_f / @size * 100).to_i
    "#{percent}%"
  end
end

discovery_endpoint = URI(ARGV[0] || 'https://api.scryfall.com/bulk-data')
endpoint_type = ARGV[1] || 'oracle_cards'
data_endpoints = JSON.parse(Net::HTTP.get(discovery_endpoint)).fetch('data')
oracle_endpoint = data_endpoints.detect { |endpoint| endpoint.fetch('type') == endpoint_type }
abort "Could not find bulk API for `#{endpoint_type}`." if oracle_endpoint.nil?

url = URI.parse(oracle_endpoint.fetch('download_uri'))
file_name = File.join(__dir__, '../data/cards.json')
Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
  request = Net::HTTP::Get.new(url)
  http.request(request) do |response|
    open(file_name, 'wb') do |file|
      progress = ProgressBar.new(size: oracle_endpoint.fetch('size'), description: 'Downloading card data')
      response.read_body do |chunk|
        file.write(chunk)
        print progress.report(chunk.size)
      end
    end
  end
end
