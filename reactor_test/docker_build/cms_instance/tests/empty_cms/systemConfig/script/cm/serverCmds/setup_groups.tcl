proc setupGroups {} {
  group create name not_root_group
  user create login not_root defaultGroup not_root_group
  user withLogin not_root set password not_root
  obj withPath / permission permissionCreateChildren grantTo not_root_group
  clearUsermanCache
}
#setupGroups
