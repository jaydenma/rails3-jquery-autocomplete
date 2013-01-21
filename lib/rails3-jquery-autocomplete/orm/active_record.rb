module Rails3JQueryAutocomplete
  module Orm
    module ActiveRecord
      def get_autocomplete_items(parameters)
        term    = parameters[:term]
        targets = parameters[:targets]
        options = parameters[:options]
        limit   = get_autocomplete_limit(options)

        search = Search.new(:keyword => term, :max_result => limit, :account_id => current_account.id)

        items = {}

        targets.each do |target|
          result = []
          reference = target.to_s.pluralize
          search.send(reference).each do |res|
            result += [res]
          end
          items.merge!(reference => result)
        end

        items
      end

    end
  end
end
