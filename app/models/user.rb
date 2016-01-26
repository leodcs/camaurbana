class User < ActiveRecord::Base
	self.primary_key = 'id'
	EMAIL_REGEXP = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
	has_many :rooms, dependent: :destroy
	has_many :reviews, dependent: :destroy
	has_many :reviewed_rooms, through: :reviews, source: :room
	validates_presence_of :email, :full_name, :location
	validates_length_of :bio, minimum: 1, allow_blank: true
	# 'ID is not a number ERROR=> ' validates_numericality_of :id, greater_than: 0
	validate :email_format

	scope :confirmed, ->  { where.not(confirmed_at: nil) }

	def self.authenticate(email, password)
		confirmed.find_by(email: email).try(:authenticate, password)
	end

	def email_format
		errors.add(:email, :invalid) unless email.match(EMAIL_REGEXP)
	end	
	
	has_secure_password
	
	before_create do |user|
		user.confirmation_token = SecureRandom.urlsafe_base64
	end

	def confirm! 
		return if confirmed?
			self.confirmed_at = Time.current
			self.confirmation_token = ''
			save!
	end

	def confirmed?
		confirmed_at.present?
	end
end
