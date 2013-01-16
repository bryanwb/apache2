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
  if node.platform_family == "debian"
    version = `apt-cache showpkg --no-all-versions apache2 | grep  head -n3 | tail -1 | cut -f1 -d\ `
  else
    version = `yum -C info httpd | grep Version | head -n1 | awk '{print $3}'`
  end
  sum_version_num(version) >= sum_version_num("2.4.2")
end

def compute_module_path
  if apache_2_4_2?
    module_path = "#{node['apache']['lib_dir']}/modules/mod_pagespeed_ap24.so"
  else
    module_path = "#{node['apache']['lib_dir']}/modules/mod_pagespeed.so"
  end
end

pagespeed_module_path = compute_module_path
package_extension = platform_family?("debian", "ubuntu") ? "deb" : "rpm"

remote_file "#{Chef::Config['file_cache_path']}/mod_pagespeed.#{package_extension}" do
  source node[:apache][:mod_pagespeed][:package][:url]
  checksum node[:apache][:mod_pagespeed][:package][:checksum]
end

package "mod-pagespeed" do
  source "#{Chef::Config['file_cache_path']}/mod_pagespeed.#{package_extension}"
end

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
