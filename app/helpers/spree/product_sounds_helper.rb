module Spree
  module ProductSoundsHelper

  	def insert_product_sound(sound, params={})
  		style = params[:style] || :mp3
  		params.delete(:style)
  		options = { skin: 'blue'}.merge(params)
  		metadata = options.keys.map{ |k| "#{k.to_s}:#{options[k].inspect}" }.join(",")
  		link_to sound.alt || "", sound.attachment.url(style), id: "m#{sound.id}", class: "audio {#{metadata}}"
  	end

  end
end
