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
    	@parameters = ["-vn", "-y"]
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
     		@bitrate ||= "192k"
      when "libvorbis"
      	# no defaults for now
      when "aac"
      	@parameters << "-strict" << "experimental"
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
