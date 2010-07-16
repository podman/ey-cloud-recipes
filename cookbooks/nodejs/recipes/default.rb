node[:applications].each do |app_name,data|
  user = node[:users].first
  
  case node[:instance_role]
    when 'util'
      if node[:name] == 'mongodb_master'
        njs_dir = "node-v0.1.100"
        njs_file = "node-v0.1.100.tar.gz"
        njs_url = "http://nodejs.org/dist/node-v0.1.100.tar.gz"

        remote_file "/data/#{njs_file}" do
          source "#{njs_url}"
          owner node[:owner_name]
          group node[:owner_name]
          mode 0644
          backup 0
          not_if { FileTest.exists?("/data/#{njs_file}") }
        end

        execute "unarchive njs-to-install" do
          command "cd /data && tar zxf #{njs_file} && sync"
          not_if { FileTest.directory?("/data/#{njs_dir}") }
        end

        execute "build njs package" do
          command "cd /data/#{njs_dir} && ./configure && make && make install"
          not_if { FileTest.exists?("/usr/local/bin/node") }
        end
        
        remote_file "/data/GeoLiteCity.dat.gz" do
          source "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
          owner node[:owner_name]
          group node[:owner_name]
          mode 0644
          backup 0
          not_if {FileTest.exists?("/data/GeoLiteCity.dat.gz")}
        end
        
        execute "unarchive geolite city db" do
          command "cd /data && tar zxf GeoLiteCity.dat.gz"
          not_if {FileTest.exists?("/data/GeoLiteCity.dat")}
        end
        
        execute "build geoip for node" do
          command "cd /data/#{app_name}/current/vendor/node/deps/node-geoip && node-waf configure build"
          nof_if {FileTest.exists?("/data/#{app_name}/current/vendor/node/deps/lib/ceoip.node")}
        end
        
      end
    end
end