node[:applications].each do |app_name,data|
  user = node[:users].first

  case node[:instance_role]
    when "solo", "app", "app_master"
      mi_dir = "MediaInfo_CLI_GNU_FromSource"
      mi_file = "MediaInfo_CLI_0.7.34_GNU_FromSource.tar.bz2"
      mi_url = "http://downloads.sourceforge.net/project/mediainfo/binary/mediainfo/0.7.34/MediaInfo_CLI_0.7.34_GNU_FromSource.tar.bz2"
      
      remote_file "/data/#{mi_file}" do
        source "#{mi_url}"
        owner node[:owner_name]
        group node[:owner_name]
        mode 0644
        backup 0
        not_if { FileTest.exists?("/data/#{mi_file}") }
      end

      execute "unarchive mi-to-install" do
        command "cd /data && tar jxf #{mi_file} && sync"
        not_if { FileTest.directory?("/data/#{mi_dir}") }
      end
      
      execute "build mi package" do
        command "cd /data/#{mi_dir} && ./CLI_Compile.sh && cd /data/#{mi_dir}/MediaInfo/Project/GNU/CLI && make install"
      end 
      
    end
  end