module Api
  module V1
    class SocialSiteController < ApplicationController

      def responses
        @errors = []
        all_tweets = get_social_site_data(ENV["TWITTER_URL"], "tweet") # get response from TWITTER_URL
        all_statuses = get_social_site_data(ENV["FACEBOOK_URL"], "status") # get response from FACEBOOK_URL
        all_pictures = get_social_site_data(ENV["INSTAGRAM_URL"], "picture") # get response from INSTAGRAM_URL
        response = { twitter: all_tweets, facebook: all_statuses, instagram: all_pictures }
        if @errors.present?
          render :json => { :errors => @errors, status: 400 }
        else
          render :json => response
        end
      end

      private

      def get_social_site_data(url, data)
        response = HTTParty.get(url) 
        if response.ok?
          hash_response = parsed_json(response.body)
          hash_response.inject([]) do |resp, each_user|
            resp << each_user[data]
            resp
          end
        else
          @errors = "#{response.message} when retreiving #{data.pluralize}"
          []
        end
      end

      def parsed_json(input_data)
        JSON.parse(input_data)
        rescue JSON::ParserError => e
        []
      end
    end
  end
end
