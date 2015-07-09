module Paperclip
  class AudioConvert < Processor

    FORMAT_CODECS = { "mp3" => "libmp3lame", 
      						    "ogg" => "libvorbis", 
      						    "m4a" => "aac", "mp4" => "aac" 
      					 		}
    FORMAT_TYPES = { "mp3" => "audio/mpeg",
    								 "ogg" => "audio/ogg",
    								 "m4a" => "audio/mp4",
    								 "mp4" => "audio/mp4"
    							 }

    def initialize file, options = {}, attachment = nil
    	super
    	@parameters = ["-vn", "-y", "-v", "error"]
    	@format = @options[:format].to_s
    	if @format.empty?
    		# default to mp3 format
      	@format = "mp3"
    	end
      @codec = @options[:codec].to_s
      if @codec.empty?
      	# determine codec to use
      	@codec = FORMAT_CODECS[@format]
      end
      @bitrate = @options[:bitrate]
      @samplerate = @options[:samplerate]
      @quality = @options[:quality]

      case @codec
      when "libmp3lame"
     		@bitrate ||= 192000
      when "libvorbis"
      	# no defaults for now
      when "aac"
      	@parameters << "-strict" << "experimental"
      end

      unless @bitrate.nil?
        original_bitrate = attachment.instance.original_bitrate ||= @bitrate
        case @options[:bitrate_adjust].to_s
        when "highest"
          @bitrate = [@bitrate, original_bitrate.to_i].max
        when "lowest"
          @bitrate = [@bitrate, original_bitrate.to_i].min
        end
      end

      unless @samplerate.nil?
        original_samplerate = attachment.instance.original_samplerate ||= @samplerate
        case @options[:samplerate_adjust].to_s
        when "highest"
          @samplerate = [@samplerate, original_samplerate.to_i].max
        when "lowest"
          @samplerate = [@samplerate, original_samplerate.to_i].min
        end
      end

      @basename = File.basename(@file.path, File.extname(@file.path))

    end

		def make
      src = @file
      dst = Tempfile.new([@basename, ".#{@format}"])
      dst.binmode

      @parameters << "-i" << ":src" << "-c:a" << @codec
      unless @bitrate.nil?
      	@parameters << "-b:a" << @bitrate
      end
      unless @samplerate.nil?
      	@parameters << "-r:a" << @samplerate
      end
      unless @quality.nil?
      	@parameters << "-q:a" << @quality
      end
      @parameters << ":dst"

			begin
        Paperclip.run("ffmpeg", @parameters.join(" "), :src => File.expand_path(src.path), :dst => File.expand_path(dst.path))
			rescue Cocaine::ExitStatusError => e
        raise Paperclip::Error, "There was an error converting the audio for #{@basename}" if @whiny
      rescue Cocaine::CommandNotFoundError => e
        raise Paperclip::Errors::CommandNotFoundError.new("Could not run the 'ffmpeg' command. Please install ffmpeg.")
      end

      dst
		end
  end
end
