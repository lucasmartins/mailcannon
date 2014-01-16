# Refinements over stdlib to avoid depending on ActiveSupport and friends.
module MailCannon
  refine Hash do
    def symbolize_keys!
      keys.each do |key|
        self[(key.to_sym rescue key) || key] = delete(key)
      end
      self
    end
    
    # Imported from https://github.com/rails/rails/blob/2ef4d5ed5cbbb2a9266c99535e5f51918ae3e3b6/activesupport/lib/active_support/core_ext/hash/deep_merge.rb
    def deep_merge(other_hash, &block)
      dup.deep_merge!(other_hash, &block)
    end

    # Same as +deep_merge+, but modifies +self+.
    def deep_merge!(other_hash, &block)
      other_hash.each_pair do |k,v|
        tv = self[k]
        if tv.is_a?(Hash) && v.is_a?(Hash)
          self[k] = tv.deep_merge(v, &block)
        else
          self[k] = block && tv ? block.call(k, tv, v) : v
        end
      end
      self
    end
  end
end