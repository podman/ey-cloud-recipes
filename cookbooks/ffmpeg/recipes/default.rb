node[:applications].each do |app_name,data|
  user = node[:users].first

  case node[:instance_role]
    when "solo", "app", "app_master", "util"
      package "media-video/ffmpeg" do
        version "0.10.3"
        action :install
      end
      
    end
  end