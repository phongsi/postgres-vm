#
# Cookbook Name:: postgres-machine
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node['postgresql']['password']['postgres'] = node["password"]

include_recipe "xfs"

directory '/data' do
  mode '0755'
end

include_recipe "postgresql::client"
include_recipe "postgresql::server"
include_recipe "database::postgresql"

postgresql_connection_info = {:host => "127.0.0.1",
                              :port => node['postgresql']['config']['port'],
                              :username => 'postgres',
                              :password => node["password"]}

postgresql_database_user node["db_user"] do
  connection postgresql_connection_info
  password node["db_password"]
  action :create
end

postgresql_database 'mirthdb' do
  connection postgresql_connection_info
  template 'DEFAULT'
  encoding 'DEFAULT'
  tablespace 'DEFAULT'
  connection_limit '-1'
  owner node["db_user"]
  action :create
end

# grant all privileges on all tables in foo db
postgresql_database_user node["db_user"] do
  connection postgresql_connection_info
  database_name 'mirthdb'
  privileges [:all]
  action :grant
end

script "start_postgres" do
  interpreter "bash"
  user "root"
  code <<-EOH
    /etc/init.d/postgresql restart
  EOH
end