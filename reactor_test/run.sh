#!/bin/bash

cat << EOF
# You may need to run the following in CM -single shell:

group create name not_root_group
user create login not_root defaultGroup not_root_group
user withLogin not_root set password not_root
obj withPath / permission permissionCreateChildren grantTo not_root_group
clearUsermanCache

EOF

bundle exec rake cm:seed:test &&
  bundle exec rake cm:migrate &&
  ./use-config.rb -e "bundle exec rake spec"
