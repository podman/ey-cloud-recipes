node[:applications].each do |app,data|
  
  template "/etc/monit.d/rtmplite.monitrc" do
    source "rtmplite.monitrc.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
  end
  
  execute "restart-monit-rtmplite" do
    command "/usr/bin/monit reload && " +
            "/usr/bin/monit restart rtmplite"
    action :run
  end
end