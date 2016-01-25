class Room < ActiveRecord::Base
	extend FriendlyId
scope :most_recent, -> {order('created_at DESC')}
has_many :reviews, dependent: :destroy
validates_presence_of :title
validates_presence_of :slug
friendly_id :title, use: [:slugged, :history]
belongs_to :user
mount_uploader :picture, PictureUploader

	def to_param
		"#{id}-#{title.parameterize}"
	end

	def complete_name
		"#{title}, #{location}"
	end

	def self.search(query)
		if query.present?
			where(['location ILIKE :query OR title ILIKE :query OR description ILIKE :query', query: "%#{query}%"])
		else
			all
		end
	end
end
