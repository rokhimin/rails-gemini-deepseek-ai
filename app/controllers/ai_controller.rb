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

    #each data
		ai_api_key.each do |data|
      @data_api = "#{data[1]}"
    end
    ai_message.each do |data|
      @data_message = "#{data[1]}"
    end

    #request API
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

        
      when ai_model == "deepseek", "llama", "liquid", "chatgpt"
        uri = URI.parse("https://openrouter.ai/api/v1/chat/completions")
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/json"
        request["Authorization"] = "Bearer #{@data_api}"

        #each data model openrouter ai
        if ai_model == "deepseek"
          ai_model_name = "deepseek/deepseek-r1-distill-qwen-32b"
        end
        if ai_model == "llama"
          ai_model_name = "meta-llama/llama-3.3-70b-instruct"
        end
        if ai_model == "liquid"
          ai_model_name = "liquid/lfm-7b"
        end
        if ai_model == "chatgpt"
          ai_model_name = "openai/gpt-4o-mini"
        end

        request.body = JSON.dump({
          "model" => ai_model_name,
          "messages" => [
            {
              "role" => "user",
              "content" => "#{@data_message}"
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

    #answer handle
    case
      when response.code == "200"
        if ai_model == "gemini"
          @answer = "#{load['candidates'][0]['content']['parts'][0]['text']}"
        end
          
        if ai_model == "deepseek" || ai_model == "llama" || ai_model == "liquid" || ai_model == "chatgpt"
          @answer = "#{load['choices'][0]['message']['content']}"
        end


      #error handling
      when response.code == "400"
        @answer = "Status : 400 Bad Request"
      when response.code == "401"
        @answer = "Status : 401 Unauthorized"
      when response.code == "403"
        @answer = "Status : 403 Forbidden"
      when response.code == "404"
        @answer = "Status : 404 Not Found"
      when response.code == "405"
        @answer = "Status : 405: Method Not Allowed"
      when response.code == "408"
        @answer = "Status : 408: Request Timeout"
      when response.code == "500"
        @answer = "Status : 500: Internal Server Error"
      when response.code == "502"
        @answer = "Status : 502: Bad Gateway"
      when response.code == "503"
        @answer = "Status : 503: Service Unavailable"
      when response.code == "504"
        @answer = "Status : 504: Gateway Timeout"

    end
    
    @model_of_ai = "AI Model : #{ai_model}"
	  render "ai/index"

  end
end
