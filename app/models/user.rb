class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: {message: "Rentrez une adresse email valide de moins de 255 caractères."}, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX, message: "Format d'email invalide" },
                    uniqueness: { case_sensitive: false }

  has_secure_password validations: false #This way we can custom validations
  validates :password, presence: true,
                       confirmation: {message: "Les mots de passe ne correspondent pas"},
                       length: { in: 6..40, message: "Rentrez un mot de passe entre 6 et 40 caractères" }
  # Everything below is for the cookies
  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    # remember_token is an instance variable
    # create a new token and add it to the User object
    self.remember_token = User.new_token
    # create a digest from this token and write it in the database
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    # verify is the remember_token correspond to the hash stored in the db
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end
