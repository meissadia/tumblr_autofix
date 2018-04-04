require 'tumblr_draftking'
require 'yaml/store'
require 'fileutils'
require 'erb'

def store(dstore, key, value)
  dstore.transaction do
    dstore[key] = value
  end
end

def restore(dstore, key, default=nil)
  dstore.transaction do
    dstore[key] || default
  end
end

def style
  %q(
    <style>
      h1,h2 { width: 100%; background-color: rgb(140, 129, 38); color: white; text-align: center; }
      ul, li { width: 100%; text-align: center; vertical-align: middle; padding: 0; margin: 0 auto;}
      ul li { list-style: none; padding: 0; margin: 0 auto; }
      ul li:hover { background-color: rgb(200, 200, 102); }
      a, a:visited { color: white; vertical-align: middle; line-height: 100px; }
    </style>
  )
end

def script
  %q(
    <script>

    </script>
  )
end

if $0 == __FILE__
data_yml = YAML::Store.new(DK::Config.home_path_file('/config_md/taf/data.yml'))
# special_yml = YAML::Store.new(DK::Config.home_path_file('summary.yml'))

# Cache config data
@last_tag = restore(data_yml, :last_tag)
@tag_idx  = restore(data_yml, :tag_idx)
@summary  = restore(data_yml, :summary)
@ignore   = restore(data_yml, :ignore)

template = '.html.erb'
fname = File.basename(__FILE__, '.rb')
tname = fname + template
tdata = File.open(tname, 'rb', &:read)
result = ERB.new(tdata).result(binding)

out_file = DK::Config.home_path_file('/config_md/taf/view_config.html')
File.open(out_file, 'w') do |f|
  f << result
end

`open #{out_file}`
end
