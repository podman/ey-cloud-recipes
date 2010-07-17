if ['solor', 'app', 'app_master'].include?(node[:instance_role])

  worker_name = "delayed_job"

  node[:applications].each do |app_name,data|
    
    directory "/data/#{app_name}/shared/pids" do
      owner node[:owner_name]
      group node[:owner_name]
      mode 0755
    end
    
    template "/etc/monit.d/delayed_job_worker.#{app_name}.monitrc" do
      source "delayed_job.monit.erb"
      owner "root"
      group "root"
      mode 0644
      variable({
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
    