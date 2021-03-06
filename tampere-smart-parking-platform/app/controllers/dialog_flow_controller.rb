class DialogFlowController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ActionView::Helpers::DateHelper

  def webhook
    parking_spot = ParkingSpot.recently_confirmed_free.first
    ParkingSpot.where(status: 'reserved').where('updated_at < ?', 1.minute.ago).update_all(status: 'free')
    parking_spot.update(status: 'reserved')
    Cache.where(key: 'map_data').update_all(invalidated: true)
    escaped_destination = CGI.escape("#{parking_spot.latitude},#{parking_spot.longitude}")

    render json: {
      payload: {
        google: {
          expectUserResponse: true,
          richResponse: {
            items: [
              {
                simpleResponse: {
                  textToSpeech: "We found a parking spot!"
                }
              },
              {
                basicCard: {
                  title: "Nearest available parking spot found at #{parking_spot.address}" || 'Nearest parking spot',
                  formattedText: "This empty spot was found #{time_ago_in_words(parking_spot.last_confirmed_free_at)} ago.\nTap on Navigate to start navigation using Google Maps.",
                  buttons: [{
                    title: 'Navigate',
                    openUrlAction: {
                      url: "https://www.google.com/maps/dir/?api=1&destination=#{escaped_destination}&travelmode=driving&dir_action=navigate"
                    }
                  }]
                }
              }
            ]
          }
        }
      }
    }
  end
end