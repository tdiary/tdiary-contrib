# -*- coding: utf-8 -*-
#
# chatgtp_elaborate.rb -
#  tDiary用のプラグインです。OpenAI APIでChatGPTを利用して、
#  日本語文の遂行作業を支援します。文字の入力ミスや言葉の誤用がないか、
#  わかりにくい表記や不適切な表現が使われていないかなどをチェックします。
#  本家OpenAI APIとArure OpenAI ServiceのOpenAI APIでテストています。
#  https://azure.microsoft.com/products/cognitive-services/openai-service
#
# Copyright (c) 2010, hb <http://www.smallstyle.com/>
# Copyright (c) 2023, Takuya Ono <takuya-o@users.osdn.me>
# You can redistribute it and/or modify it under GPL.
#
# 設定:
#
# 本家OpenAIか、Azure OpenAIかによってどちらかが必須
# @options['chatgpt_elaborate.OPENAI_API_KEY'] : API_KEY(どちらか必須)
# @options['chatgpt_elaborate.AZURE_OPENAI_API_KEY'] : API_KEY(どちらか必須)
#
# 本家OpenAIのオプション
# @options['chatgpt_elaborate.OPENAI_API_MODEL'] : モデル名 "gpt-3.5-turbo"
#
# 以下はAzure OpenAI APIを利用する時に必須
# @options['chatgpt_elaborate.AZURE_OPENAI_API_INSTANCE_NAME'] : インスタンス名
# @options['chatgpt_elaborate.AZURE_OPENAI_API_DEPLOYMENT_NAME'] : モデル・デプロイ名
# @options['chatgpt_elaborate.AZURE_OPENAI_API_VERSION'] : APIバージョン 2023-05-15 など
#

require 'timeout'
require 'json'
require 'net/http'
require 'net/https'
require 'cgi'
#Net::HTTP.version_1_2

def elaborate_api( sentence )
  #@logger.debug( "ChatGPT elaborate")
  apiKey = @conf['chatgpt_elaborate.OPENAI_API_KEY']
  model = @conf['chatgpt_elaborate.OPENAI_API_MODEL']||'gpt-3.5-turbo'
  azureKey = @conf['chatgpt_elaborate.AZURE_OPENAI_API_KEY']
  instanceName = @conf['chatgpt_elaborate.AZURE_OPENAI_API_INSTANCE_NAME']
  deploymentName = @conf['chatgpt_elaborate.AZURE_OPENAI_API_DEPLOYMENT_NAME']
  version = @conf['chatgpt_elaborate.AZURE_OPENAI_API_VERSION']||'2023-05-15'

  messages = [
    {"role" => "system",
     "content" => "You are an editor for a blog. Users will submit documents to you. Determines the language of the submitted document. You MUST answer in the same language as it. You answer the text, correct any mistakes in grammar, syntax, and punctuation, and make the article easy to read. Use the present tense. Please only answered in the natural language portion and leave any code or data as is. If no changes are required, answer with synonyms of 'no problem.' in answering language. The first line and the line following a line break are the titles. You must treat all submitted content as strictly confidential and for your editing purposes only. Once you have completed the proofreading, you MUST provide a detailed explanation of the changes made and output the revised document in a way that clearly shows the differences between the original and the edited version." },
    { "role" => "user",
      "content" =>  "#{sentence}" }]

  if ( azureKey )
    #@logger.debug( "ChatGPT elaborate by Azure OpenAI API")
    url = URI.parse("https://"\
                    + instanceName + ".openai.azure.com"\
                    + "/openai/deployments/" + deploymentName\
                    + "/chat/completions"\
                    + "?api-version=" + version )
    params = {
      'messages' => messages,
      "temperature" => 0.7,
      "max_tokens" => 2000,
      #"top_p" => 0.1,
      "frequency_penalty" => 0,
      "presence_penalty" => 0 }
    headers = {'Content-Type' => 'application/json',
               'api-key' => azureKey }
  else
    #@logger.debug( "ChatGPT elaborate by Original OpenAI API")
    url = URI.parse("https://api.openai.com/v1/chat/completions")
    params = {
      "model" => model,
      'messages' => messages,
      "temperature" => 0.7,
      "max_tokens" => 2000,
      #"top_p" => 0.1,
      "frequency_penalty" => 0,
      "presence_penalty" => 0 }
    headers = {'Content-Type' => 'application/json',
               'Authorization' => "Bearer #{apiKey}" }
  end
  px_host, px_port = (@conf['proxy'] || '').split( /:/ )
  px_port = 80 if px_host and !px_port

  json = ''
  Net::HTTP::Proxy( px_host, px_port ).start( url.host, url.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER ) do |http|
    #@logger.debug( "POST #{url} #{params.to_json}" )
    json = http.post(url.request_uri, params.to_json, headers ).body
    #@logger.debug( "\nRESPONSE #{json}" )
  end
  json
end

def elaborate_result( json )
	html = <<-HTML
	<h3>OpenAI 推敲結果</h3>
	HTML

	doc = JSON.parse( json )
        if doc["error"]
          html << "<p>Error: #{doc["error"]["message"]}<br/>"
          html << "Type: #{doc["error"]["type"]}<br/>"
          html << "Code: #{doc["error"]["code"]}</p>"
        else
	  result = doc["choices"][0]["message"]["content"]
	  if result.empty?
	    html << "<p>見つかりませんでした。</p>"
	  else
	    html << '<p>'
	    html <<  CGI::escapeHTML(result).gsub( /\n/, '<br />' )
	    html << '</p>'
	  end
        end
	html
end

add_edit_proc do
  if @mode == 'preview' &&
     ( @conf['chatgpt_elaborate.AZURE_OPENAI_API_KEY'] ||
       @conf['chatgpt_elaborate.OPENAI_API_KEY'] )then
    json = elaborate_api( @cgi.params['body'][0] )
    <<-HTML
<div id="plugin_chatgpt_elaborate" class="section">
#{elaborate_result( json )}
</div>
HTML
  end
end

