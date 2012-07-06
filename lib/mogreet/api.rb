require 'rexml/document'
require 'net/http'

module Mogreet
  module Api
  
    ##
    # Helper method to make a get request without having to remember Net::HTTP's funky syntax.
    def self.fetch(path, params = {})
    
      extra_params = params.collect do |k,v| 
        "#{k}=#{URI.escape(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
      end.join('&')
    
      api_call = "https://api.mogreet.com#{path}?client_id=#{Mogreet::App.settings.client_id}&token=#{Mogreet::App.settings.token}&#{extra_params}"
      url = URI.parse(api_call)

      # initialize net http
      http = Net::HTTP.new( url.host, url.port )
    
      # set ssl
      if url.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Get.new( url.request_uri )

      # submit request
      body = http.request(request).body
      puts body
      body
    end  
  
    ##
    # Sample response
    # <?xml version="1.0" encoding="UTF-8"?>
    # <response status="success" code="1">
    #   <message>list created</message>
    #   <list id="1124"/>
    # </response>
    def self.create_list(name)
      path = "/cm/list.create"
    
      raw_xml = fetch(path, :name => name)    
      xml = ::REXML::Document.new(raw_xml)
      list_id = xml.elements.to_a('response').first.elements.to_a('list').first.attributes['id'] rescue nil    
      raise raw_xml if list_id.nil?
      list_id
    end
  
    ##
    # Sample response
    # <?xml version="1.0" encoding="UTF-8"?>
    # <response status="success" code="1">
    #   <message>queued</message>
    # </response>
    # 
    # Supported Parameters
    # list_id: The unique identification number for the list you wish to initiate a delivery to.
    # campaign_id: The id of the campaign which determines the message flow, and default behavior for the blast.
    # subject: The subject line of the message, used in MMS.
    # message: The text of the message you wish to deliver. The text should be in ASCII text, avoid special characters. Remember to URL-­‐encode the entire API call string.
    # content_id: The Mogreet content_id describing the item of content (audio, image, video, etc) you wish to be delivered to the target handset. In most cases this will be delivered as a single MMS. In cases where the carrier or handset will not support the content type, an SMS with a link to the content hosted via mobile web page may be substituted.
    # content_url: A URL describing the location of a content file, to be ingested, transcoded, and used in the list.send, and delivered to all the handsets. Delivered as
    # MMS where possible, as SMS with a link to a mobile page where no MMS is available. Content items are cached for reuse, and deleted from the cache after a period of time. See Appendix A for details on allowed file types and specifications.
    # to_name: A label to be added where possible in the message subject. Ex. to_name=Toastmasters would add the address 'Toastmasters' to the message.
    # from_name: A label to identify the sender. The messages will show the shortcode (or long code) of the campaign as the canonical sender, this label is used only in the message body or subject line. (fact check...)
    # udp_*: user defined parameters which may be added to pass in specific information for custom campaign logic.
    def self.send_list(params)
      path = "/cm/list.send"
      params[:campaign_id] ||= CAMPAIGN_ID
      raw_xml = fetch(path, params)    
      xml = ::REXML::Document.new(raw_xml)
      message = xml.elements.to_a('response').first.elements.to_a('message').first.text rescue nil    
      raise raw_xml unless message == 'queued'
      true
    end
  
    ##
    #
    # <?xml version="1.0" encoding="UTF-8"?>
    # <response status="success" code="1">
    #  <message>request processed</message>
    #  <statistics>
    #    <created>1</created>
    #    <duplicate>0</duplicate>
    #    <rejected>0</rejected>
    #  </statistics>
    # </response>
    # Supported Parameters
    # list_id
    # numbers
    def self.add_to_list(params)
      path = "/cm/list.append"

      raw_xml = fetch(path, params)    
      xml = ::REXML::Document.new(raw_xml)
      status = xml.elements.to_a('response').first.attributes['status'] rescue nil    
      raise raw_xml unless status == 'success'
      true
    end

    ##
    #
    # <?xml version="1.0" encoding="UTF-8"?>
    # <response status="success" code="1">
    #  <message>request processed</message>
    #  <statistics>
    #    <created>1</created>
    #    <duplicate>0</duplicate>
    #    <rejected>0</rejected>
    #  </statistics>
    # </response>
    # Supported Parameters
    # list_id
    # numbers
    def self.remove_from_list(params)
      path = "/cm/list.prune"

      raw_xml = fetch(path, params)    
      xml = ::REXML::Document.new(raw_xml)
      status = xml.elements.to_a('response').first.attributes['status'] rescue nil    
      raise raw_xml unless status == 'success'
      true
    end
  
    def self.list_list(params)
      path = "/cm/list.list"

      raw_xml = fetch(path, params)    
      raw_xml
    end

    def self.list_download(params)
      path = "/cm/list.download"

      raw_xml = fetch(path, params)    
      raw_xml
    end
  
    def self.ping(params = {})
      path = "/cm/system.ping"

      raw_xml = fetch(path, params)    
      raw_xml    
    end
  
    ##
    # params: to, message, content_url
    # client_id Your client id. Log onto the Campaign Manager to access your client id.
    # token Your token. Log onto the Campaign Manager to access your token.
    # campaign_id An ID connected to a specific campaign setup in the Campaign Manager or provided by your account representative.
    # to The mobile number (MSISDN) of the handset you would like to send to.
    # from The mobile number (MSISDN) of the handset you would like to send from. Or the shortcode associated with the campaign. (Optional – if not included, this parameter will default to the shortcode associated to the campaign).
    # message Depending on your campaign set up, the message presented to the “to” user.
    # content_id An integer value associated to a piece of content ingested through the Campaign Manager. You’ll find all your content ids under the media
    # section. (Optional – depending on your campaign set up, this parameter may be required)
    # content_url A publicly accessible URL of an image, audio or video. MOMS will automagically ingest the content and deliver it as specified by the
    # campaign flow. (Optional -­‐ depending on your campaign set up, this parameter may be required)
    # to_name DEPRECATED see udp_* parameter below -­‐ Depending on your campaign setup, you may provide the receiver’s name along with the message.
    # from_name DEPRECATED see udp_* parameter below -­‐ Depending on your campaign setup, you may provide the sender’s name along with the message.
    # callback This is an optional parameter. If provided with a valid URL, any errors with the transaction will be sent to this URL
    def self.single_send(params)
      pcopy = params.dup
      path = "/moms/transaction.send"
      pcopy[:campaign_id] ||= (pcopy[:content_url].nil? && pcopy[:content_id].nil?) ? Mogreet::App.settings.sms_campaign_id : Mogreet::App.settings.mms_campaign_id
      raw_xml = fetch(path, pcopy)    
      xml = ::REXML::Document.new(raw_xml)
      status = xml.elements.to_a('response').first.attributes['status'] rescue nil    
      raise raw_xml unless status == 'success'
      true
    end
  end
    
end
