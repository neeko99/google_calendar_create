require 'byebug'
require "google/apis/calendar_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "date"
require "fileutils"
require 'active_record'

OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Clacks Bins".freeze
CREDENTIALS_PATH = "credentials.json".freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = "token.yaml".freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = "default"
  credentials = authorizer.get_credentials user_id
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts "Open the following URL in the browser and enter the " \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize


# Fetch the next 10 events for the user
calendar_id = "puzzelcasemanagement@gmail.com"

supporters = ['@Moanna', '@Olalekan Eyiowuawi', '@Christian Galamay', '@Nick Longmore', '@Mark J Lynch' ,'@Campbell Miller', '@Gino Cortez']

start_date = Date.new(2022, 04, 11)
1.times do |week|
  supporters.length.times do |index|
    start_date += (7 * index)
    # backup = supporters[index + 1].presence || supporters[0]
    backup = 'Nick'
    title = "Support this week is #{supporters[index]} with #{backup} as backup"


    event = Google::Apis::CalendarV3::Event.new(
      summary: title,
      start: Google::Apis::CalendarV3::EventDateTime.new(date: start_date),
      end: Google::Apis::CalendarV3::EventDateTime.new(date: (start_date + 5).to_s)
    )
    service.insert_event(
      calendar_id,
      event
    )
  end
end
