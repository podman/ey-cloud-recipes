if node[:instance_role] == 'util' && node[:name].match(/^mongodb_/)
  template "/etc/monit.d/vid2s3.monitrc" do
    source "vid2s3.monitrc.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
  end
  
  execute "restart-monit-vid2s3" do
    command "/usr/bin/monit reload && " +
            "/usr/bin/monit restart vid2s3"
    action :run
  end
end