class Round < ActiveRecord::Base
  validates :judge_id,
    presence: true

  validates :tweet_id,
    presence: true,
    uniqueness: {
      scope: [ :judge_id ],
    }

  belongs_to :judge, class_name: "User"
  belongs_to :tweet

  has_many :hashtags, dependent: :destroy
  has_many :users, through: :hashtags

  default_scope -> { order("created_at DESC") }
  scope :open, -> { where(status: ["open", "submission_complete"]) }
  scope :closed, -> { where(status: "closed") }

  class << self
    def close_all
      Round.open.update_all(status: :closed)
    end

    def generate(*args)
      Round.close_all

      round = Round.new(*args)
      round.select_tweet

      round
    end
  end

  def check_submissions
    if self.hashtags.incomplete == 0
      self.update_attributes(status: :submission_complete)

      return true
    end

    false
  end

  def close
    self.update_attributes(status: :closed)
  end

  def select_tweet
    self.tweet = Tweet.offset(rand(Tweet.count)).limit(1).first
  end
end
