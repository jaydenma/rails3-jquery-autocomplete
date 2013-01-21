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
      def autocomplete(name, targets = [], options = {})
        define_method("autocomplete_#{name}") do

          term = params[:term]
          items = {}
          
          if term && !term.blank?
            items = get_autocomplete_items(:term => term, :options => options, :targets => targets)
          end

          render :json => json_for_autocomplete(items, options[:display_values])
        end
      end
    end

    # Returns a limit that will be used on the query
    # Need to modify this to work properly.. now this does.. x*10 queries, where x is the number of model
    def get_autocomplete_limit(options)
      options[:limit] ||= 5
    end

    # Returns parameter model_sym as a constant
    #
    #   get_object(:actor)
    #   # returns a Actor constant supposing it is already defined
    def get_object(model_sym)
      object = model_sym.to_s.camelize.constantize
    end

    # Returns a hash with keys actually used by the Autocomplete jQuery-ui
    # Can be overriden to show the value you like
    def json_for_autocomplete(items, display_values={})
      result = []

      items.each do |item_with_category|  
        result += [{ "value" => item_with_category.first.sub(/data_/,'').pluralize.titleize, "class" => "autocomplete_header" }]
        result += item_with_category.second.collect do |item|
          #if there are no display values, take name
          display_value = !display_values.nil? ? display_values[ item.class.name.underscore.to_sym ] : "name"
          hash = { "id" => item.id, "label" => item.send( display_value ), "value" => item.send( display_value ) }

          hash
        end

      end

      result
    end
  end
end

