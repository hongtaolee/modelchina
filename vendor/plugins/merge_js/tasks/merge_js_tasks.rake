require 'yaml'

desc "Merge and compress javascript files"
task :merge_js => :environment do
  # set reference paths
  jsmin_path = "#{RAILS_ROOT}/vendor/plugins/merge_js/lib/"
  js_path = "#{RAILS_ROOT}/public/javascripts/"

  # load js yaml file
  js_yml = YAML.load_file("#{RAILS_ROOT}/config/js.yml")

  old_version = js_yml['current_version']
  current_version = Time.new.strftime("%Y%m%d%H%M%S")
  
  source_map = js_yml['source_map']

  # create target hash
  target_files = Hash.new
  
  # loop through array
  source_map.each do |file_hash|
    target_file = file_hash.keys.first
    source_files = file_hash[target_file]

    source_files.each do |source_file|
      File.open("#{js_path}#{source_file}.js", "r") do |f|
        if target_files.has_key?(target_file)
          target_files[target_file] += "\n" + f.read
        else
          target_files[target_file] = f.read
        end
      end
    end
  end
  
  # loop through target hash
  target_files.keys.each do |target_file|
    # write out to a temp file
    File.open("#{js_path}#{target_file}_temp.js", "w") {|f| f.write(target_files[target_file]) }
    
    # compress file with JSMin
    `ruby #{jsmin_path}jsmin.rb <#{js_path}#{target_file}_temp.js >#{js_path}#{target_file}_#{current_version}.js \n`

    # delete temp file if it exists
    File.delete("#{js_path}#{target_file}_temp.js") if File.exists?("#{js_path}#{target_file}_temp.js")

    # delete old version if it exists
    File.delete("#{js_path}#{target_file}_#{old_version}.js") if File.exists?("#{js_path}#{target_file}_#{old_version}.js")
  end
  
  # update yaml with current version
  js_yml['current_version'] = current_version
  
  File.open("#{RAILS_ROOT}/config/js.yml", "w") do |out|
    YAML.dump(js_yml, out)
  end

end

desc "Generate js.yml from your existing javascript files"
task :generate_js_yml => :environment do
  # only run if js.yml doesn't already exist
  if !File.exists?("#{RAILS_ROOT}/config/js.yml")
    current_version = Time.new.strftime("%Y%m%d%H%M%S")
    file_list = Array.new
    
    # get list of files in /public/javascripts
    # reverse the list so for a default rails app, 
    # prototype comes first, and application comes last
    Dir::open("#{RAILS_ROOT}/public/javascripts/").entries.reverse.each do |file|
      file_list << file.chomp(".js") if !file.index(".js", -3).nil?
    end

    js_yml = Hash.new
    js_yml['source_map'] = [{"base" => file_list}]
    js_yml['current_version'] = current_version
    
    File.open("#{RAILS_ROOT}/config/js.yml", "w") do |out|
      YAML.dump(js_yml, out)
    end

    puts "config/js.yml example file created!"
    puts "Please reorder files under 'base' so dependencies are loaded in correct order."
  end
end