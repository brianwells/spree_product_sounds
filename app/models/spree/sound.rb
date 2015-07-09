module Spree
	class Sound < Asset

    validate :no_attachment_errors

	  has_attached_file :attachment,
                      styles: { 
                         original: { format: :mp3, bitrate: 192000, samplerate: 44100, 
                                     bitrate_adjust: :lowest, samplerate_adjust: :lowest }, 
                      },
                      processors: [:audio_convert],
											url: "/spree/sounds/:id/:style/:basename.:extension",
											path: ":rails_root/public/spree/sounds/:id/:style/:basename.:extension"
    validates_attachment :attachment,
                         :presence => true,
                         :content_type => { :content_type => /\Aaudio/ }

		before_post_process :skip_invalid_audio

    attr_accessor :original_bitrate, :original_samplerate

    def no_attachment_errors
    	unless attachment.errors.empty?
        errors.add :attachment, "Paperclip returned errors for file '#{attachment_file_name}' - check sound source file."
        false
      end
    end

    private

    def skip_invalid_audio
    	# TODO: check file to make sure it has audio that ffmpeg can access
      file_path = attachment.queued_for_write[:original].path
      file_info = JSON.parse(`ffprobe -v error #{file_path} -print_format json -show_streams`)
      return false if file_info["streams"].nil? || !file_info["streams"].is_a?(Array)
      file_info["streams"].each do |stream|
        if stream["codec_type"] == "audio"
          self.original_bitrate = stream["bit_rate"]
          self.original_samplerate = stream["sample_rate"]
          return true 
        end
      end
    	false
    end
	end
end
