class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]
  # protect_from_forgery with: :null_session

  def callback
    body = request.body.read
    # p body
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: "text",
            text: event.message["text"]
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :ok
  end

  # CHANNEL_SECRET = '...' # Channel secret string
  # http_request_body = request.raw_post # Request body string
  # hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
  # signature = Base64.strict_encode64(hash)

  private def client 
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end
