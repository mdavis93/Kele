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
    can_choose = []
    mentor_id = get_me['current_enrollment']['mentor_id']
    response = self.class.get("/mentors/#{mentor_id}/student_availability", headers: {authorization: @auth_token})

    JSON.parse(response.body).each do |avail|
      if avail['booked'].nil?
        can_choose << avail
      end
    end

    can_choose
  end

  def get_messages(page = nil)
    if page.nil?
      response = self.class.get('/message_threads', headers: { authorization: @auth_token })
    else
      response = self.class.get('/message_threads', body: { page: page }, headers: { authorization: @auth_token })
    end

    JSON.parse(response.body)
  end

  def create_message(recipient_id, subject, msg, token = nil)
    msg_data = "{
    'sender': #{get_me['email']},
    'recipient_id': #{recipient_id},
    'token': #{token},
    'subject': #{subject},
    'stripped-text': #{msg}
    }"

    response = self.class.post('/messages', header: { authorization: @auth_token }, body: msg_data)

    puts "Message Sent Successfully!" if response.success?
  end
end
