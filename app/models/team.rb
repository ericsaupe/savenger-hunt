# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :hunt
  has_many :submissions, dependent: :destroy
  has_many :items, through: :submissions

  validates :name, uniqueness: {scope: :hunt, case_sensitive: false}

  after_create_commit { broadcast_append_to("teams_#{hunt_id}") }
  after_update_commit { broadcast_replace(partial: "teams/score") }

  def score
    submissions.with_points.includes(item: :category).with_attached_photo.sum { |submission| submission.item.category.points }
  end
end
