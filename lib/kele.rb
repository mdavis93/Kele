require 'httparty'
require 'json'
require './lib/roadmap'

class Kele
  include HTTParty
  include Roadmap
  
  base_uri "https://www.bloc.io/api/v1"

  def initialize(email, password)
    post_response = self.class.post("/sessions", body: {email: email, password: password})
    @auth_token = post_response['auth_token']

    raise "Invalid Login Credentials" if @auth_token.nil?
  end

  def get_me
    response = self.class.get("/users/me", headers: {authorization: @auth_token} )
    JSON.parse(response.body)
  end

  def get_mentor_availability
    canChoose = []
    mentor_id = get_me['current_enrollment']['mentor_id']
    response = self.class.get("/mentors/#{mentor_id}/student_availability", headers: {authorization: @auth_token})

    JSON.parse(response.body).each do |avail|
      if avail['booked'].nil?
        canChoose << avail
      end
    end

    canChoose
  end
end
