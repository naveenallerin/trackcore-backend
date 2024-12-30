module CacheableAssociations
  extend ActiveSupport::Concern

  class_methods do
    def cache_belongs_to(association_name, options = {})
      # Define the belongs_to association first
      belongs_to(association_name, **options)

      # Define the cached method
      define_method("cached_#{association_name}") do
        Rails.cache.fetch([self.class.name, id, association_name]) do
          public_send(association_name)
        end
      end
    end
  end
end
