node[:applications].each do |app_name,data|
  user = node[:users].first
  
  case node[:instance_role]
    when 'util'
      execute 'start-god' do
        command "god -c /data/#{app_name}/current/config/god.rb"
      end
  end
end