module SpreedlyCore
  class Gateway < Base
    attr_reader(:name, :token, :gateway_type, :auth_modes, :supports_capture,
                :supports_authorize, :supports_purchase, :supports_void,
                :supports_credit, :supports_reference_purchase, :supports_offsite_purchase, :payment_methods, :redacted)

    # returns an array of Gateway which are supported
    def self.supported_gateways
      verify_options("/gateways.xml") do |response|
        response.parsed_response["gateways"]["gateway"].map{|h| new(h) }
      end
    end

    # returns an array of all the Gateways owned by the account
    def self.all
      verify_get("/gateways.xml") do |response|
        # will return Hash if only 1 gateways->gateway, Array otherwise
        gateways =  begin
                      response.parsed_response["gateways"]["gateway"]
                    rescue
                      nil
                    end
        if gateways
          gateways = [gateways] unless gateways.is_a?(Array)
          
          return gateways.collect{|gateway_hash| new gateway_hash}
        end
      end

      return []
    end

    def self.create(gateway_options)
      raise ArgumentError.new("gateway_options must be a hash") unless gateway_options.is_a?(Hash)
      
      opts = {
        :headers => {"Content-Type" => "application/xml"},
        :body => gateway_options.to_xml(:root => :gateway, :dasherize => false),
      }

      verify_post("/gateways.xml", opts) do |response|
        return new response.parsed_response["gateway"]
      end
    end

    # Update the attributes of a gateway
    def self.update(token, gateway_options)
      opts = {
        :headers => {"Content-Type" => "application/xml"},
        :body => gateway_options.to_xml(:root => :gateway, :dasherize => false)
      }

      verify_put("/gateways/#{token}.xml", opts) do |response|
        return new response.parsed_response["gateway"]
      end
    end

    # Redact sensitive attributes of a gateway
    def self.redact(token)
      verify_put("/gateways/#{token}/redact.xml", body: {}, has_key: 'transaction') do |response|
        return new response.parsed_response["transaction"]
      end
    end

    def initialize(attrs={})
      attrs.merge!(attrs.delete("characteristics") || {})
      super(attrs)
    end

    def use!
      self.class.gateway_token = self.token
    end

    def ==(other)
      self.token == other.token
    end
  end
end
