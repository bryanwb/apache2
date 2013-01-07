#
# Cookbook Name:: apache2
# Recipe:: php5
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
  v_nums = version.split(".").each {|str| str.to_i }
  (vnums[0] * 1000) + (vnums[1] * 100) + vnums[2]
end

def version_2_4_2?
  version = `httpd -v | head -n1`.match(/(\d\.\d.\d\d)/)[0]
  sum_version_num(version) >= sum_version_num("2.4.2")
end

base_url = "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_"

arch = node.kernel.machine =~ /i[36]86/ ? "i386" : "x86_64"

case node['platform_family']
when "debian"
  remote_file "#{Chef::Config['file_cache_path']}/mod_pagespeed.deb" do
    source "#{base_url}#{arch}.deb"
  end
  package "mod-pagespeed" do
    source "#{Chef::Config['file_cache_path']}/mod_pagespeed.deb"
  end
when "rhel"
  remote_file "#{Chef::Config['file_cache_path']}/mod_pagespeed.rpm" do
    source "#{base_url}#{arch}.rpm"
  end
  package "mod-pagespeed" do
    source "#{Chef::Config['file_cache_path']}/mod_pagespeed.rpm"
  end

   [ "pagespeed_libraries.conf", "pagespeed.conf" ].each do |f|
    file "/etc/httpd/conf.d/#{f}" do
      action :delete
      backup false
    end
  end
end

apache_module "pagespeed" do
  conf true
  if apache_version < "2.4.2"
    module_path "#{node['apache']['lib_dir']}/mod_pagespeed.so"
  else
    module_path "#{node['apache']['lib_dir']}/mod_pagespeed_ap24.so"
  end
end

apache_module "pagespeed_libraries" do
  conf true
end

