if ['solor', 'app', 'app_master'].include?(node[:instance_role])

  worker_name = "delayed_job"

  node[:applications].each do |app_name,data|
    
    remote_file "/engineyard/bin/dj" do
      owner "root"
      group "root"
      mode 0755
      source "dj"
    end
    
    worker_count = 1
    
    case node[:ec2][:instance_type]
    when 'm1.small': worker_count = 2
    when 'c1.medium': worker_count = 4
    when 'c1.xlarge': worker_count = 8
    else
      worker_count = 2
    end
    
    worker_count.times do |count|
      template "/etc/monit.d/delayed_job_worker.#{count+1}.#{app_name}.monitrc" do
        source "delayed_job.monit.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :worker_name => "#{app_name}_deplayed_job_#{count+1}",
          :framework_env => node[:environment][:framework_env]
        })
      end
    end
    
    bash "monit-reload-restart" do
      user "root"
      code "pkill -9 monit && monit"
    end
    
  end
end
    