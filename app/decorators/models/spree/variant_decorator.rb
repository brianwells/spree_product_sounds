Spree::Variant.class_eval do
  has_many :sounds, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: "Spree::Sound"
end