module Spree
	class Sound < Asset

    validate :no_attachment_errors

	has_attached_file :attachment,
                      styles: { 
                         mp3: { format: :mp3, bitrate: "192K", samplerate: 44100 }, 
                      },
                      processors: [:audio_convert],
											url: "/spree/sounds/:id/:style/:basename.:extension",
											path: ":rails_root/public/spree/sounds/:id/:style/:basename.:extension"
    validates_attachment :attachment,
                         :presence => true,
                         :content_type => { :content_type => /\Aaudio/ }

		before_post_process :skip_invalid_audio

    def no_attachment_errors
    	unless attachment.errors.empty?
        errors.add :attachment, "Paperclip returned errors for file '#{attachment_file_name}' - check sound source file."
        false
      end
    end

    private

    def skip_invalid_audio
    	# TODO: check file to make sure it has audio that ffmpeg can access
    	true
    end
	end
end
