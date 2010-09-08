#
# Cookbook Name:: solr
# Recipe:: default
#
 
require 'digest/sha1'
if node[:instance_role] == 'app_master'
node[:applications].each do |app,data|
 
  directory "/data/#{app}/jettyapps" do
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
    recursive true
  end
 
  directory "/var/run/solr" do
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
    recursive true
  end
 
  template "/engineyard/bin/solr" do
    source "solr.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0755
    variables({
      :rails_env => node[:environment][:framework_env],
      :app => app
    })
  end
 
  template "/etc/monit.d/solr.#{app}.monitrc" do
    source "solr.monitrc.erb"
    owner node[:owner_name]
    group node[:owner_name]
    mode 0644
    variables({
      :app => app,
      :user => node[:owner_name],
      :group => node[:owner_name]
    })
  end
 
  execute "install solr example package" do
    user node[:owner_name]
    group node[:owner_name]
    command("if [ ! -e /data/#{app}/jettyapps/solr ]; then cd /data/#{app}/jettyapps && " +
            "wget -O apache-solr-1.4.0.tgz http://mirror.cc.columbia.edu/pub/software/apache/lucene/solr/1.4.0/apache-solr-1.4.0.tgz && " +
            "tar -xzf apache-solr-1.4.0.tgz && " +
            "mv apache-solr-1.4.0/example solr && " +
            "rm -rf apache-solr-1.4.0; fi")
    action :run
  end
 
  gem_package "sunspot_rails" do
    source "http://gemcutter.org"
    action :install
  end
  
  gem_package "nokogiri" do
    source "http://gemcutter.org"
    action :install
  end
 
  execute "install-sunspot-solr" do
    user node[:owner_name]
    group node[:owner_name]
    command "sunspot-installer -f /data/#{app}/jettyapps/solr/solr"
    action :run
  end
  
  execute "restart-monit-solr" do
    command "/usr/bin/monit reload && " +
            "/usr/bin/monit restart all -g solr_#{app}"
    action :run
  end
 
end
end