module Rails3JQueryAutocomplete
  module Orm
    module ActiveRecord
      def get_autocomplete_items(parameters)
        term    = parameters[:term]
        options = parameters[:options]
        limit   = get_autocomplete_limit(options)

        search = Search.new(:keyword => term, :max_result => limit)

        items = {}

        result = []
        search.data_organizations.each do |res|
          result += [res]
        end
        items.merge!("Organizations" => result)

        result = []
        search.data_users.each do |res|
          result += [res]
        end
        items.merge!("Users" => result)

        result = []
        search.data_workstations.each do |res|
          result += [res]
        end
        items.merge!("Workstations" => result)

        result = []
        search.data_servers.each do |res|
          result += [res]
        end
        items.merge!("Servers" => result)

        result = []
        search.data_network_devices.each do |res|
          result += [res]
        end
        items.merge!("Network Devices" => result)

        result = []
        search.data_softwares.each do |res|
          result += [res]
        end
        items.merge!("Softwares" => result)

        items
      end

    end
  end
end
