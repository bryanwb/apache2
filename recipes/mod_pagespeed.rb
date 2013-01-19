#
# Cookbook Name:: apache2
# Recipe:: mod_pagespeed
#
# Copyright 2013 Bryan W. Berry
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def sum_version_num(version)
  v_nums = version.split(".").map {|str| str.to_i }
  third_num = v_nums[2] < 10 ? v_nums[2] * 10 : v_nums[2]
  (v_nums[0] * 1000) + (v_nums[1] * 100) + third_num
end

def apache_2_4_2?
  sum_version_num(node[:apache][:candidate_version]) >= sum_version_num("2.4.2")
end

def compute_module_path
  if apache_2_4_2?
    module_path = "#{node['apache']['lib_dir']}/modules/mod_pagespeed_ap24.so"
  else
    module_path = "#{node['apache']['lib_dir']}/modules/mod_pagespeed.so"
  end
end

if node.platform_family == "debian" or node.platform_family == "rhel"

  case node.platform_family
  when "debian"
    apache2_status_cmd = Chef::ShellOut.new("dpkg -s apache2")
    apache2_status_cmd.run_command
    apache2_installed = apache2_status_cmd.status == 0 ? true : false
    candidate_cmd = "apt-cache showpkg --no-all-versions apache2 | head -n3 | tail -1 | cut -f1 -d\\ "

    r = ruby_block "get_apache_candidate" do
      block do
        cmd = Chef::ShellOut.new(candidate_cmd)
        cmd.run_command
        cmd.error!
        node[:apache][:candidate_version] = cmd.stdout.rstrip
      end
      action :nothing
    end
    r.run_action :create


    remote_file "#{Chef::Config['file_cache_path']}/mod_pagespeed.deb" do
      source node[:apache][:mod_pagespeed][:package][:url]
      checksum node[:apache][:mod_pagespeed][:package][:checksum]
      mode "0755"
    end

    node[:apache][:candidate_version] =~ /^(2.\d).*/
    apache_version = $1
    package "apache#{apache_version}-common"
    dpkg_package "mod-pagespeed" do
      source "#{Chef::Config['file_cache_path']}/mod_pagespeed.#{package_extension}"
    end
  when "rhel"
    apache2_status_cmd = Chef::ShellOut.new("rpm -qa httpd")
    apache2_status_cmd.run_command
    apache2_installed = apache2_status.stdout.empty? ? false : true
    candidate_cmd = "yum info httpd | grep Version | head -n1 | awk '{print $3}'"

    r = ruby_block "get_apache_candidate" do
    block do
      cmd = Chef::ShellOut.new(candidate_cmd)
      cmd.run_command
      cmd.error!
      node[:apache][:candidate_version] = cmd.stdout.rstrip
    end
    action :nothing
    end
    r.run_action :create
    
    remote_file "#{Chef::Config['file_cache_path']}/mod_pagespeed.rpm" do
      source node[:apache][:mod_pagespeed][:package][:url]
      checksum node[:apache][:mod_pagespeed][:package][:checksum]
      mode "0755"
    end

    package "mod-pagespeed" do
      source "#{Chef::Config['file_cache_path']}/mod_pagespeed.#{package_extension}"
    end
  end

end

pagespeed_module_path = compute_module_path
  
[ "pagespeed_libraries.conf", "pagespeed.conf" ].each do |f|
  file "/etc/httpd/conf.d/#{f}" do
    action :delete
    backup false
  end
end

apache_module "pagespeed" do
  conf true
  module_path pagespeed_module_path
end

apache_conf "pagespeed_libraries" do
  conf true
end
