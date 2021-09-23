require 'rails_helper'

describe Api::V1::SocialSiteController, :type => :controller, :dbclean => :after_each do

  let(:http_response_headers) {{ foo: :bar}}
  let(:twitt_http_response) do
  	double({
  	  status: http_status_code,
  	  headers: http_response_headers,
  	  body: twitt_response_body,
  	  ok?: http_status,
  	  message: http_message

  	})
  end
  let(:fb_http_response) do
  	double({
  	  status: http_status_code,
  	  headers: http_response_headers,
  	  body: fb_response_body,
  	  ok?: http_status,
  	  message: http_message

  	})
  end
  let(:insta_http_response) do
  	double({
  	  status: http_status_code,
  	  headers: http_response_headers,
  	  body: insta_response_body,
  	  ok?: http_status,
  	  message: http_message

  	})
  end
  subject { get :responses }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("FACEBOOK_URL").and_return(Faker::Internet.url)
    allow(ENV).to receive(:[]).with("INSTAGRAM_URL").and_return(Faker::Internet.url)
    allow(ENV).to receive(:[]).with("TWITTER_URL").and_return(Faker::Internet.url)
    allow(HTTParty).to receive(:get).with(ENV["TWITTER_URL"]).and_return(twitt_http_response)
    allow(HTTParty).to receive(:get).with(ENV["FACEBOOK_URL"]).and_return(fb_http_response)
    allow(HTTParty).to receive(:get).with(ENV["INSTAGRAM_URL"]).and_return(insta_http_response)
  end

  describe '#responses' do

  	before { subject }

    context 'response succeeds' do
      let(:http_status_code) { 200 }
      let(:http_status) { true }
      let(:http_message) { nil }

      context "all httparty has json responses" do
      
        let(:twitt_response_body) { "[{ \"username\":\"@sam\",\"tweet\":\"my tweet\"}]" }
        let(:insta_response_body) { "[{ \"username\":\"@har\",\"picture\":\"my picture\"}]" }
        let(:fb_response_body)    { "[{ \"username\":\"@var\",\"status\":\"my status\"}]" }
        
        it "HTTParty call succeeds" do
          expect(response.status).to eq(200)
          expect(response.parsed_body).to eq(
            {"twitter"=>["my tweet"], "facebook"=>["my status"], "instagram"=>["my picture"]}
          )
        end
      end

      context 'return empty array if the response is json' do
        let(:twitt_response_body) { "not a json response" }
        let(:insta_response_body) { "[{ \"username\":\"@har\",\"picture\":\"my picture\"}]" }
        let(:fb_response_body)    { "[{ \"username\":\"@var\",\"status\":\"my status\"}]" }
      
        it "HTTParty call succeeds" do
          expect(response.status).to eq(200)
          expect(response.parsed_body).to eq(
          {"twitter"=>[], "facebook"=>["my status"], "instagram"=>["my picture"]}
          )
        end
      end
    end

    context 'return empty array if the response is json' do
      let(:http_status_code) { 400 }
      let(:http_status) { false }
      let(:http_message) { "unable to reach server" }
      let(:twitt_response_body) { "error" }
      let(:insta_response_body) { "error" }
      let(:fb_response_body)    { "error" }

      it "HTTParty call succeeds" do
        expect(JSON.parse(response.body)["status"]).to eq(400)
        expect(JSON.parse(response.body)["errors"]).to eq("unable to reach server when retreiving pictures")
      end
    end
  end
end
