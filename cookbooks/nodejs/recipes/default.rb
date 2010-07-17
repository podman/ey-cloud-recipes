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
        
        remote_file "/data/GeoIP.tar.gz" do
          source "http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz"
          owner node[:owner_name]
          group node[:owner_name]
          mode 0644
          backup 0
          not_if {FileTest.exists?("/data/GeoIP.tar.gz")}
        end
        
        execute "unarchive geoip api" do
          command "cd /data && tar xzf GeoIP.tar.gz"
          not_if {FileTest.directory?("/data/GeoIP-1.4.6")}
        end
        
        execute "build geoip api" do
          command "cd /data/GeoIP-1.4.6 && ./configure && make && make check && make install"
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
          command "cd /data && gunzip GeoLiteCity.dat.gz"
          not_if {FileTest.exists?("/data/GeoLiteCity.dat")}
        end
        
        execute "build geoip for node" do
          command "cd /data/#{app_name}/current/vendor/node/deps/node-geoip && node-waf configure build"
          not_if {FileTest.exists?("/data/#{app_name}/current/vendor/node/deps/lib/ceoip.node")}
        end
        
        template "/etc/monit.d/nodejs.monitrc" do
          source "nodejs.monit.erb"
          owner "root"
          group "root"
          mode 0644
          variables({
            :app_name => app_name,
            :user => node[:owner_name],
            :worker_name => worker_name,
            :framework_env => node[:environment][:framework_env]
          })
        end

        bash "monit-reload-restart" do
          user "root"
          code "pkill -9 monit && monit"
        end
        
      end
    end
end