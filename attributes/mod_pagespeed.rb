#
# Author:: Bryan W. Berry <bryan.berry@gmail.com>
# Copyright:: Copyright (c) 2012, Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default[:apache][:mod_pagespeed][:domains] = [ node.fqdn ]
default[:apache][:mod_pagespeed][:stats_visibility] = "127.0.0.1"
default[:apache][:mod_pagespeed][:version] = "stable"
default[:apache][:mod_pagespeed][:rewrite_level] = "CoreFilters"
default[:apache][:mod_pagespeed][:rewrite_deadline] = "10"
default[:apache][:mod_pagespeed][:packages] = {
  :beta =>  {
    :deb => {
      :i386 => {
        :url => "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_i386.deb",
        :checksum => "95eff40e38c5da0a53e5b201efaa309dbb005019a5199c145ffd75066cad953f"
      },
      :x86_64 => {
        :url =>  "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_amd64.deb",
        :checksum => "14c531ee29979f94af64cecf9d1bc1223733e3328553b66d868795c20f479fb6"
      }
    },
    :rpm => {
      :i386 => {
        :url => "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_i386.rpm",
        :checksum => "73854ede8e8c308956a3398d215b127cbad356862f1665444c2f05b1597adbdf"
      },
      :x86_64 => {
        :url =>  "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_x86_64.rpm",
        :checksum => "05f755f5273a72e4dfd9db32e9c3acba1a719e68f1dd9bd6b1ce41ae4de27476"
      }
    }
  },
  :stable =>  {
    :deb => {
      :i386 => {
        :url => "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_i386.deb",
        :checksum => "92470fe796798c89c16ca6810295ef9f1a6fc7c252d6b0c325441c352b658342"
      },
      :x86_64 => {
        :url =>  "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb",
        :checksum => "e96394e51edd4a1b2a568918c48dd2f7460ea2c5d1b1333de1f93582a860948e"
      }
    },
    :rpm => {
      :i386 => {
        :url => "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_i386.rpm",
        :checksum => "007cfddcc0e5de8abb80a1965ca644f8795eb748b87e6a82d5d9d0492c82e8ee",
      },
      :x86_64 => {
        :url =>  "https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm",
        :checksum => "42718840f5cbbd35f564460dd806b7be668bcb765ae45d321eaf1b741d11d225"
      }
    }
  }
}

version = node[:apache][:mod_pagespeed][:version]
node_pkg_type = node.platform_family == "debian" ? :deb : :rpm
node_arch = node.kernel.machine =~ /i[356]86/ ? :i386 : :x86_64
package = node[:apache][:mod_pagespeed][:packages][version][node_pkg_type][node_arch]

default[:apache][:mod_pagespeed][:package] = {
  :url => package[:url],
  :checksum => package[:checksum]
}

default[:apache][:mod_pagespeed][:filters] = {
  :enable => [],
  :disable => [],
  :forbid => []
}

default[:apache][:mod_pagespeed][:file_cache] = {
  :size_kb => "102400",
  :clean_interval => "3600000",
  :inode_limit => "500000"
}

default[:apache][:mod_pagespeed][:lru_cache] = {
  :kb_per_process => "1024",
  :byte_limit => "16384"
}

