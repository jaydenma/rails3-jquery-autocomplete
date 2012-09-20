module Rails3JQueryAutocomplete
  module Autocomplete
    def self.included(target)
      target.extend Rails3JQueryAutocomplete::Autocomplete::ClassMethods

      if defined?(Mongoid::Document)
        target.send :include, Rails3JQueryAutocomplete::Orm::Mongoid
      elsif defined?(MongoMapper::Document)
        target.send :include, Rails3JQueryAutocomplete::Orm::MongoMapper
      else
        target.send :include, Rails3JQueryAutocomplete::Orm::ActiveRecord
      end
    end

    #
    # Usage:
    #
    # class ProductsController < Admin::BaseController
    #   autocomplete :brand_and_products_search, { :brand => [:name, :description], :product => [:name, :description]  }
    # end
    #
    # This will magically generate an action autocomplete_brand_and_products_search, so,
    # don't forget to add it on your routes file
    #
    #   resources :products do
    #      get :autocomplete_brand_and_products_search, :on => :collection
    #   end
    #
    # Now, on your view, all you have to do is have a text field like:
    #
    #   f.text_field :brand_or_products_name, :autocomplete => autocomplete_brand_and_products_search_products_path
    #
    #
    # Yajl is used by default to encode results, if you want to use a different encoder
    # you can specify your custom encoder via block
    #
    # class ProductsController < Admin::BaseController
    #   autocomplete :brand, :name do |items|
    #     CustomJSONEncoder.encode(items)
    #   end
    # end
    #
    module ClassMethods
      def autocomplete(name, targets, options = {})
        define_method("autocomplete_#{name}") do

          term = params[:term]
          items = []
          
          if term && !term.blank?
            targets.each do |object, methods|
              methods.each do |method|
                items += ( get_autocomplete_items(:model => get_object( object ), \
                :options => options, :term => term, :method => method ) )
              end
            end
          else
            items = []
          end

          render :json => json_for_autocomplete(items, targets, options[:display_values], options[:extra_data])
        end
      end
    end

    # Returns a limit that will be used on the query
    def get_autocomplete_limit(options)
      options[:limit] ||= 10
    end

    # Returns parameter model_sym as a constant
    #
    #   get_object(:actor)
    #   # returns a Actor constant supposing it is already defined
    #
    def get_object(model_sym)
      object = model_sym.to_s.camelize.constantize
    end

    #
    # Returns a hash with three keys actually used by the Autocomplete jQuery-ui
    # Can be overriden to show whatever you like
    # Hash also includes a key/value pair for each method in extra_data
    #
#    def json_for_autocomplete(items, method, extra_data=[])
#      items.collect do |item|
#        hash = {"id" => item.id.to_s, "label" => item.send(method), "value" => item.send(method)}
#        extra_data.each do |datum|
#          hash[datum] = item.send(datum)
#        end if extra_data
#        # TODO: Come back to remove this if clause when test suite is better
#        hash
#      end
#    end
    
    def json_for_autocomplete(items, targets, display_values={}, extra_data={})
      items.collect do |item|
        display_value = display_values[ item.class.name.downcase.to_sym ] ? display_values[ item.class.name.downcase.to_sym ] : targets[ item.class.name.downcase.to_sym ][0] 
        hash = { "id" => item.id, "label" => item.send( display_value ), "value" => item.send( display_value ), "type" => item.class.name.downcase }
        extra_data[ item.class.name.downcase.to_sym ].each do |datum|
          hash[datum] = item.send(datum)
        end if extra_data[ item.class.name.downcase.to_sym ]
        hash
      end
    end
  end
end

