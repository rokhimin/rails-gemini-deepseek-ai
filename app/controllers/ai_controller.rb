require 'open-uri'
require 'net/http'
require 'json'

class AiController < ApplicationController
  protect_from_forgery prepend: true
	skip_before_action :verify_authenticity_token

  def post

		#initialize 
    ai_api_key = params[:api_key]
    ai_model = params[:model]
    ai_message = params[:message]

		ai_api_key.each do |data|
      @data_api = "#{data[1]}"
    end

    ai_message.each do |data|
      @data_message = "#{data[1]}"
    end

    case 
      when ai_model == "gemini"

      uri = URI.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{@data_api}")
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/json"
        request.body = JSON.dump({
          "contents" => [
            {
              "parts" => [
                {
                  "text" => "#{@data_message}"
                }
              ]
            }
          ]
        })
      
        req_options = {
          use_ssl: uri.scheme == "https",
        }
      
        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
        load = JSON.parse(response.body)
     
    end

        @status = "Status : #{response.code}"

    # Error Handling
    rescue NoMethodError 
      @answer = "fill out the form"
    else
      @answer = "#{load['candidates'][0]['content']['parts'][0]['text']}"
    

  
	  render "ai/index"

  end
end
