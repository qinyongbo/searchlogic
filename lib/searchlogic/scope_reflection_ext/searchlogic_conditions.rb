module Searchlogic
  module ScopeReflectionExt
    module SearchlogicConditions
      def searchlogic_methods
        ##Assign a method on acitve Rcord
        ## Define method on Conditions => condition then knows about all of it's subclasses
        #Searchlogic::ActiveRecordExt::Scopes::Conditions::Condition.all_matchers
        ActiveRecord::Base.all_matchers
      end

      def all_scopes
        searchlogic_methods + aliases + all_named_scopes.map(&:to_s)
      end
    end
  end
end