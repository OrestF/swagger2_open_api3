require 'net/http'
require 'net/https'

class Swagger2OpenApi3
  class NoContentError < StandardError; end

  URL = 'https://converter.swagger.io/api/convert'.freeze

  def self.from_commandline
    new(ARGV[0], ARGV[1]).call
  end

  def initialize(path_or_content, output = nil)
    raise NoContentError unless present?(path_or_content)
    @body  = File.exists?(path_or_content) ? File.read(path_or_content) : path_or_content

    raise NoContentError unless present?(@body)

    @uri = ::URI.parse(URL)
    @client = ::Net::HTTP.new(@uri.host, @uri.port)
    @client.use_ssl = true
    @req = ::Net::HTTP::Post.new(@uri.path, headers)
    @req.body = @body
    @output = output
  end

  def call
    make_request

    respond
  end

  private

  def make_request
    @result = client.request(@req).body
  end

  attr_reader :response, :uri, :client, :result, :output

  def respond
    if present?(output)
      File.open(output, 'w'){ |f| f.write(result); f.close }
    else
      puts result
    end
  end

  def headers
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Access-Control-Allow-Headers' => 'Content-Type, api_key, Authorization'
    }
  end

  def present?(p)
    p && !p.empty?
  end
end

Swagger2OpenApi.from_commandline
