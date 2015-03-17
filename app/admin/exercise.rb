ActiveAdmin.register Exercise do

  permit_params :author_id, :language, :guide_id, :title, :description, :test, :hint, :locale

  filter :title
  filter :locale
  filter :created_at
  filter :updated_at

  index do
    column(:id)
    column(:title)
    column(:language) { |ex| I18n.t("#{ex.language.name}") }
    column(:submissions_count)
    column(:author_name) { |ex| ex.author.name }
    column(:locale)

    actions
  end
end
