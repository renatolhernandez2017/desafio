module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      user_id = Rails.application.message_verifier(:user).verify(token)
      User.find(user_id)
    rescue => e
      reject_unauthorized_connection
    end
  end
end
