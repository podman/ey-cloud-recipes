if ['app', 'app_master'].include?(node[:instance_role])
	template "/etc/nginx/servers/keep.sproutvideo.conf" do
		source "server.conf.erb"
		owner node[:owner_name]
		group node[:owner_name]
		mode 0755
	end

	template "/etc/nginx/servers/keep.sproutvideo.ssl.conf" do
		source "server.ssl.conf.erb"
		owner node[:owner_name]
		group node[:owner_name]
		mode 0755
	end
end