module Api
  module V1
    class SocialSiteController < ApplicationController

      def responses
        @errors = []
        all_tweets = get_social_site_data('https://takehome.io/twitter', "tweet")
        all_statuses = get_social_site_data('https://takehome.io/facebook', "status")
        all_pictures = get_social_site_data('https://takehome.io/instagram', "picture")
        response = { twitter: all_tweets, facebook: all_statuses, instagram: all_pictures }
        if @errors.present?
          render :json => { :errors => @errors }
        else
          render :json => response
        end
      end

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
