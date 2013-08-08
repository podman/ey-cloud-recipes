if ['app', 'app_master'].include?(node[:instance_role])
	template "/etc/nginx/servers/keep.sproutvideo.conf" do
		source "server.conf.erb"
		owner node[:owner_name]
		group node[:owner_name]
		mode 0644
	end

	template "/etc/nginx/servers/keep.sproutvideo.ssl.conf" do
		source "server.ssl.conf.erb"
		owner node[:owner_name]
		group node[:owner_name]
		mode 0644
	end

	execute "remove default config" do
		command "rm /etc/nginx/servers/sproutvideo.conf"
		only_if { FileTest.exists?("/etc/nginx/servers/sproutvideo.conf") }
	end

	execute "remove default ssl config" do
		command "rm /etc/nginx/servers/sproutvideo.ssl.conf"
		only_if { FileTest.exists?("/etc/nginx/servers/sproutvideo.ssl.conf") } 
	end

	execute "restarting nginx" do
		command "/etc/init.d/nginx restart"
	end
end