Spree::Product.class_eval do
  
  delegate :sounds, to: :master, prefix: true
	alias_method :sounds, :master_sounds

  has_many :variant_sounds, -> { order(:position) }, source: :sounds, through: :variants_including_master
   
end
