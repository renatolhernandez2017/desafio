class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable

  MAX_FAILED_ATTEMPTS = 5
  LOCK_TIME = 60.minutes

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :confirmable

  validates :name, presence: true, length: {in: 3..255}

  validates :username, presence: true, uniqueness: {case_sensitive: false}, length: {in: 5..50},
    format: {with: /\A[a-zA-Z0-9\-_]+\z/, message: "só permite letras, números, '-' e '_'"}

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true, length: {in: 20..100}, confirmation: true, if: -> { password.present? || new_record? }

  def locked?
    locked_at.present? && locked_at > LOCK_TIME.ago
  end

  def increment_failed_attempts!
    increment = failed_attempts.to_i + 1
    success = update(failed_attempts: increment)

    lock_account! if success && increment >= MAX_FAILED_ATTEMPTS
    success
  end

  def reset_failed_attempts!
    update!(failed_attempts: 0)
  end

  def lock_account!
    update!(
      locked_at: Time.current,
      unlock_token: SecureRandom.hex(10)
    )
  end

  def unlock_account!
    update!(failed_attempts: 0, locked_at: nil, unlock_token: nil)
  end
end
