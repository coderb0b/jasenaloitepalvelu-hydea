module Haka
	require 'open-uri'

  # Haka Authentication for a SAML Service Provider
  class AuthController < ApplicationController
  	skip_before_action :verify_authenticity_token

    # Initiates a new SAML sign in request
    def new
      request = OneLogin::RubySaml::Authrequest.new
      redirect_to(request.create(saml_settings))
    end

    # Receives the SAML assertion after Haka sign in
    def consume
      response = OneLogin::RubySaml::Response.new(params[:SAMLResponse],
                                                  settings: saml_settings,
                                                  allowed_clock_drift: 300.seconds)

      

      
      unless response.is_valid?
        Rails.logger.error "Invalid SAML response: #{response.errors}"
        Rollbar.error "Invalid SAML response", errors: response.errors

        redirect_to frontend_error_path("invalid_saml_response")
        return
      end

	#Asetetaan metadatan pohjalta attribuuttien nimet
	metadata=Nokogiri::HTML(open("https://rr.funet.fi/rr/metadata.php?view&type=sp&id=843&fed=1"))
	uniquecode=metadata.xpath("//entitydescriptor[@entityid='https://hydea.localhost.fifi.fi']//requestedattribute[@friendlyname='schacPersonalUniqueCode']").first.attributes["name"].value
	mail=metadata.xpath("//entitydescriptor[@entityid='https://hydea.localhost.fifi.fi']//requestedattribute[@friendlyname='mail']").first.attributes["name"].value
	displayname=metadata.xpath("//entitydescriptor[@entityid='https://hydea.localhost.fifi.fi']//requestedattribute[@friendlyname='displayName']").first.attributes["name"].value
	homeorganization=metadata.xpath("//entitydescriptor[@entityid='https://hydea.localhost.fifi.fi']//requestedattribute[@friendlyname='schacHomeOrganization']").first.attributes["name"].value

      #Kirjataan käyttäjä sisään, jos löytyy jo olemassa
      if (user = User.find_by persistent_id: response.attributes[uniquecode])
      session[:user_id] = user.id if not user.nil?
      redirect_to ideas_path
      return
      end

      #Tai luodaan uusi käyttäjä joka kirjataan sisään

      user = User.new
      user.moderator = false
      user.admin = false
      user.name = response.attributes[displayname]
      user.email = response.attributes[mail]
      user.title = ''
      user.persistent_id = response.attributes[uniquecode]
      user.save
      session[:user_id] = user.id

      redirect_to ideas_path
    end

    private
    begin

      def frontend_error_path(failure_key)
        "/#/sign-in-error?failure=#{failure_key}"
      end

      def frontend_signin_path(token)
        "/#/sign-in?token=#{token}"
      end

      def saml_settings
        settings = OneLogin::RubySaml::Settings.new

        # Require identity provider to (re)authenticate user also when a
        # previously authenticated session is still valid.
        settings.force_authn = true

        settings.idp_entity_id                  = Hydea::Haka::SAML_IDP_ENTITY_ID
        settings.idp_sso_target_url             = Hydea::Haka::SAML_IDP_SSO_TARGET_URL
        settings.assertion_consumer_service_url = Hydea::Haka::SAML_ASSERTION_CONSUMER_SERVICE_URL
        settings.issuer                         = Hydea::Haka::SAML_MY_ENTITY_ID
        settings.idp_cert                       = Hydea::Haka::SAML_IDP_CERT
        settings.name_identifier_format         = Hydea::Haka::SAML_NAME_IDENTIFIER_FORMAT

        settings.certificate                    = Hydea::Haka::SAML_MY_CERT
        settings.private_key                    = Hydea::Haka::SAML_MY_PRIVATE_KEY    

        

           

        # Fingerprint can be used in local testing instead of a cert.
        # When SAML assertions are encrypted, an actual cert is required and
        # fingerprint can be left blank.
        if Hydea::Haka::SAML_IDP_CERT_FINGERPRINT.present?
          settings.idp_cert_fingerprint         = Hydea::Haka::SAML_IDP_CERT_FINGERPRINT
        end

        settings
      end

    end

  end
end
