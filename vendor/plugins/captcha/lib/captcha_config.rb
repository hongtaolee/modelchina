#captcha_config.rb

module AngryMidgetPluginsInc #:nodoc


	# This module provides configuration options to the
	# other CAPTCHA classes. There is an optional configuration
	# file in <tt>config/captcha.yml</tt> that can be used
	# to specify application-wide options. The file is in YAML
	# format, and contains a hash with key/value pairs.
	# 
	# To generate an example <tt>captcha.yml</tt>, run
	# 
	# <tt>script/generate captcha config</tt>
	# 
	# in your applications root directory.
	# 
	# The available options are (listed by key name):
	# 
	# * default_ttl - The default TTL (time to live) for new challenges, in seconds.
	# * default_dir - The default directory where generated images are saved.
	# * default_filetype - The default extension (and file type) for generated images.
	# * words - An array of words used when rendering the text in the generated images.
	# * store - Where to store the PStore file holding the challenge objects. Default is in <tt>var/data/captchas.pstore</tt>
	# 
	# All of these values (except +store+) can be overridden in the provided helper methods.
	# 
	# *Note*: Changes to the <tt>captcha.yml</tt> file do not take effect until the server is restarted.
	module CaptchaConfig

		extend self#hm?

		DEFAULT_PSTORE_LOCATION = File.join('var', 'data', 'captchas.pstore')
		CONFIG_LOCATION = File.join(RAILS_ROOT, 'config', 'captcha.yml')
		@@pstore = nil
		@@config = nil


		# Returns the hash from the YAML configuration file.
		def config
			return @@config if @@config
			
			if File.exists?(CONFIG_LOCATION)
				@@config = YAML.load_file(CONFIG_LOCATION)
			else
				@@config = {}
			end
			
			@@config
		end


		# Returns the PStore instance used to store the
		# CAPTCHA challenges.
		def store
			@@pstore ||= PStore.new(
				File.join(RAILS_ROOT, (self.config['store'] || DEFAULT_PSTORE_LOCATION))
			)

			@@pstore
		end


	end#module Config


end#module AngryMidgetPluginsInc
