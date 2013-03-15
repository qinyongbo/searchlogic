module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Or < Condition
          attr_reader :joins_values, :where_values
          def initialize(*args)
            super
            @joins_values ||= []
            @where_values ||= []
          end

          def scope
            if applicable?
              methods_array.each do |m|
                send_and_store(m)
              end
              !joins_values.flatten.empty? ? klass.includes(joins_values.flatten).where(where_values.flatten.join(" OR ")) : klass.where(where_values.flatten.join(" OR "))
            end
          end
            def self.matcher
              nil
            end
          private

          def send_and_store(m)
            scope_key = ScopeReflection.scope_name(m)              
            if no_arg_scope?(scope_key)
              scope = klass.send(m)
              store_values(scope)
            else
              [value].flatten.size == 1 ? scope = klass.send(add_condition(m), value) : scope = klass.send(add_condition(m), *value)                
            end            
            store_values(scope)
          end

          def no_arg_scope?(scope_key)
            !!(ScopeReflection.all_named_scopes_hash[scope_key].try(:[], :scope).try(:arity) == 0)
          end

          def store_values(scope)
            joins_values << scope.joins_values
            wv = scope.where_values
            combined_values = wv.count > 1 ? wv.join(" AND ") : wv 
            where_values << combined_values
          end

          def value
            [args].flatten.size == 1 ? args.first : args
          end


          def methods_array
            join_equal_to(method_without_ending_condition.split("_or_"))            
          end

          def method_without_ending_condition
            method_name.to_s.chomp(ending_alias_condition)
          end

            def join_equal_to(method_array)
              methods = []
              method_array.each_with_index do |item, index| 
                if item == "equal" || item == "equal_to"
                  methods.delete_at(-1)
                  methods << [method_array[index-1], item ].join("_or_")
                else
                  methods << item
                end
              end
              methods
            end

            def find_condition
              klass.joined_condition_klasses.split("|").find{ |jck| last_method.include?(jck)}
            end

            def add_condition(method)
              if (has_condition?(method) && ending_alias_condition != "_any" && ending_alias_condition != "_all") || scope?(method)
                method 
              else
                method + ending_alias_condition
              end
            end

            def has_condition?(method)
              !!(/(#{ScopeReflection.aliases.join("|")}|#{self.class.all_matchers.join("|")})/.match(method) )
            end
            def scope?(method)
              !!(ScopeReflection.all_named_scopes_hash[method.to_sym])
            end
            def ending_alias_condition 
              return nil if /#{ScopeReflection.joined_named_scopes}$/ =~ method_name && ScopeReflection.joined_named_scopes
              begin
                /(#{self.class.all_matchers.sort_by(&:size).reverse.join("|")})$/.match(method_name)[0]
              rescue NoMethodError => e
                raise NoConditionError.new(e)
              end
            end

            def applicable? 
              return nil if /(find_or_)/ =~ method_name 
              named_scopes = klass.named_scopes.keys.map(&:to_s).join("|")
              !(/_or_(#{klass.column_names.join("|")}|#{klass.association_names.join("|")}#{'|'+ named_scopes unless named_scopes.empty?})/ =~ method_name).nil? 
            end

        end
      end
    end
  end
end