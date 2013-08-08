node[:applications].each do |app_name,data|
  user = node[:users].first

  case node[:instance_role]
    when "solo", "app", "app_master", "util"
      enable_package "media-video/mediainfo" do
        version "0.7.64"
      end

      package "media-video/mediainfo" do
        version "0.7.64"
        action :upgrade
      end
      
    end
  end