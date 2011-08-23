module MergeJsHelper
  def javascript_include_merged(*sources)
    options = sources.last.is_a?(Hash) ? sources.pop.stringify_keys : { }

    if sources.include?(:defaults) 
      sources = sources[0..(sources.index(:defaults))] + 
        ['prototype', 'effects', 'dragdrop', 'controls'] + 
        (File.exists?("#{RAILS_ROOT}/public/javascripts/application.js") ? ['application'] : []) + 
        sources[(sources.index(:defaults) + 1)..sources.length]
      sources.delete(:defaults)
    end 
    
    sources.collect!{|s| s.to_s}
    if RAILS_ENV == "production" && $js_yml['source_map']
      current_version = $js_yml['current_version']
      source_map = $js_yml['source_map']

      files = Array.new
      # loop through source map 
      source_map.each do |file_hash|
        target_file = file_hash.keys.first
        source_files = file_hash[target_file]
    
        source_files.each do |source_file|
          if sources.include?(source_file) 
            files << "#{target_file}_#{current_version}" if !files.include?("#{target_file}_#{current_version}")
            sources.delete(source_file)
          end
        end
      end
      files += sources # add in any files not found in the source_map
    else
      files = sources
    end
    
    files.collect {|file| javascript_include_tag(file, options) }.join("\n")
  end

  private
    # rewrite compute_public_path to not put in query string timestamp
    # used by ActionView::Helpers::AssetTagHelper
    def compute_public_path(source, dir, ext)
      source  = "/#{dir}/#{source}" unless source.first == "/" || source.include?(":")
      source << ".#{ext}" unless source.split("/").last.include?(".")
      source  = "#{@controller.request.relative_url_root}#{source}" unless %r{^[-a-z]+://} =~ source
      source = ActionController::Base.asset_host + source unless source.include?(":")
      source
    end
end