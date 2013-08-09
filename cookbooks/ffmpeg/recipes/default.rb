node[:applications].each do |app_name,data|
  user = node[:users].first

  case node[:instance_role]
    when "solo", "app", "app_master", "util"
      enable_package "media-video/ffmpeg" do
        version "1.2.1"
      end

      package "media-video/ffmpeg" do
        version "1.2.1"
        action :upgrade
      end
      
    end
  end