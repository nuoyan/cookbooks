#
# Cookbook Name:: ssh_known_hosts
# Recipe:: default
#
# Copyright 2009, Adapp, Inc.

sleep 2
nodes = []
search(:node, "*:*") do |z|
  # Prior to first chef-client run, the current node may not have attributes from search
  if z.name == node.name
    z["hostname"] = node["hostname"]
    z["ipaddress"] = node["ipaddress"]
    z["keys"] = node["keys"]
  end

  begin
    if z['keys']['ssh']['host_dsa_public'].nil?
      Chef::Log.warn("ssh_known_hosts: Attribute ['keys']['ssh']['host_dsa_public'] does not exist on node #{z.name}. Skipping node.")
      next
    elsif z['keys']['ssh']['host_rsa_public'].nil?
      Chef::Log.warn("ssh_known_hosts: Attribute ['keys']['ssh']['host_rsa_public'] does not exist on node #{z.name}. Skipping node.")
      next
    end
  rescue
    Chef::Log.warn("ssh_known_hosts: Attribute ['keys']['ssh'] does not exist on node #{z.name}. Skipping node.")
    next
  end

  # Skip the node if it doesn't have one or more of these attributes
  if z["hostname"].nil? || z["ipaddress"].nil? || z["keys"].nil?
    Chef::Log.warn("Could not find one or more of these attributes on node #{z.name}: hostname, ipaddress, keys. Skipping node.")
  else
    nodes << z
  end

end

template "/etc/ssh/ssh_known_hosts" do
  source "known_hosts.erb"
  mode 0440
  owner "root"
  group "root"
  backup false
  variables(
    :nodes => nodes
  )
end