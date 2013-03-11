module Searchlogic
  module SearchExt
    module AuthorizedScopes
    
      private

        def authorized_scope?(scope) 
          !!(ScopeReflection.all_scopes.detect{ |ks| scope.to_s.include?(ks.to_s)} || ordering?(scope))
        end
        
        def associated_column?(method)
          !!(klass.reflect_on_all_associations.detect{|associaton| method.to_s.include?(associaton.name.to_s)})
        end
    end
  end
end