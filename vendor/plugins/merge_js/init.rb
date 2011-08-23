require 'yaml'

ActionView::Base.send :include, MergeJsHelper
$js_yml = File.exists?("#{RAILS_ROOT}/config/js.yml") ? YAML.load_file("#{RAILS_ROOT}/config/js.yml") : {}