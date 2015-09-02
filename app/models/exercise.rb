class Exercise < ActiveRecord::Base
	extend FriendlyId
  friendly_id :generate_custom_slug, use: :slugged
#  	friendly_id :name, use: :slugged
#friendly_id :slug_candidates, use: :slugged

  #we are saying that we want to use
  INDEXED_ATTRIBUTES = {
      against: [:title, :description],
      associated_against: {
          language: [:name],
          tags: [:name],
          guide: [:name]
      },
  }

  include WithSearch, WithTeaser,
          WithMarkup, WithAuthor,
          WithSolutions, WithGuide,
          WithLocale, WithExpectations,
          WithLanguage,
          WithQueries

  acts_as_taggable


  enum layout: [:editor_right, :editor_bottom, :no_editor, :scratchy]

  after_initialize :defaults, if: :new_record?

  validates_presence_of :title, :description, :language, :test,
                        :submissions_count, :author

  scope :by_tag, lambda { |tag| tagged_with(tag) if tag.present? }

  markup_on :description, :hint, :teaser, :corollary


  def self.create_or_update_for_import!(guide, original_id, options)
    exercise = find_or_initialize_by(original_id: original_id, guide_id: guide.id)
    exercise.assign_attributes(options)
    exercise.save!
  end

  def search_tags
    tag_list + [language.name]
  end

  def generate_original_id!
    update!(original_id: id) unless original_id
  end

  def collaborator?(user)
    guide.present? && guide.authored_by?(user)
  end

  def extra_code
    [guide.try(&:extra_code), self[:extra_code]].compact.join("\n")
  end

  def expectations
    super + guide_expectations
  end

  private

  def defaults
    self.submissions_count = 0
    self.layout = Exercise.default_layout
  end

  def self.default_layout
    layouts.keys[0]
  end

  def name #FIXME remove
    title
  end

  def guide_expectations
    if guide.present? then guide.expectations else [] end
  end

  def slug_candidates
    [
      :name,
      [:name, guide_id]
    ]
  end

  def generate_custom_slug
    "#{name}-#{guide_id}"
  end
end
