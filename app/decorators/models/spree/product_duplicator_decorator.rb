module Spree
  module ProductDuplicatorSoundDecorator

    def duplicate_master
      master = product.master
      new_master = super
      if new_master
      	new_master.sounds = master.sounds.map { |sound| duplicate_sound sound } if @include_images
      end
      new_master
    end

    def duplicate_sound(sound)
      new_sound = sound.dup
      new_sound.assign_attributes(:attachment => sound.attachment.clone)
      new_sound
    end

  end

  Spree::ProductDuplicator.class_eval do
    prepend ProductDuplicatorSoundDecorator
  end
end
