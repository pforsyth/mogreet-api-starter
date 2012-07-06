require 'sinatra/base'
require 'sinatra/config_file'
require File.join(File.dirname(__FILE__), 'api')

module Mogreet
  class App < Sinatra::Base

    register Sinatra::ConfigFile
    
    config_file File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config','mogreet.yml'))
        
    get '/' do
      "hello world"
    end    
    
    # Sample callback XML, along with curl command for testing locally. You should fill
    # in the appropriate values in the XML for campaign_id and msisdn.
    #
    # curl -X POST -H 'Content-type: application/xml' -d @callback.xml http://localhost:5000/callback
    # <?xml version="1.0"?>
    # <mogreet>
    #   <campaign_id>NNNNN</campaign_id>
    #   <msisdn>13109999999</msisdn>
    #   <carrier><![CDATA[T-Mobile]]></carrier>
    #   <message><![CDATA[YourKeyword Hi this is a test.]]></message>
    #   <subject><![CDATA[]]></subject>
    #   <images>
    #     <image><![CDATA[http://d2c.bandcon.mogreet.com/mo-mms/images/141598_12630691.jpeg]]></image>
    #   </images>
    # </mogreet>
    post '/callback' do      
      xml = request.body.read
      puts "Received xml: #{xml}"
      if xml.nil? || xml == ''
        $stderr.print "Hello callback, seems like you didn't post any xml. Here are the params: #{params.inspect}\n"
      else        

        # parse XML from callback
        xml_doc = Nokogiri::XML(xml)
        xml_hash = {
          :msisdn       => xml_doc.at('msisdn').text,
          :carrier      => xml_doc.at('carrier').text,
          :campaign_id  => xml_doc.at('campaign_id').text,
          :message      => xml_doc.at('message').text,
        }
        xml_hash[:subject]   = xml_doc.at('subject').text      rescue nil
        xml_hash[:image_url] = xml_doc.at('images/image').text rescue nil

        # Do someting based on what was texted in. Look at subject and message.
        # 
        # sub = xml_hash[:subject].to_s.downcase.split(/\W/)
        # mes = xml_hash[:message].to_s.downcase.split(/\W/)
        # commands = (sub+mes).delete_if{|word| word.empty?}.uniq
        # if commands.any? {|c| c == 'text_in_value'}          
        # end

        # For testing, just hard-code a static message that responds to the sender
        Mogreet::Api.single_send(:to => xml_hash[:msisdn], :message => 'Thanks for the message!')        
      end
      'OK'
    end
    
  end
end
