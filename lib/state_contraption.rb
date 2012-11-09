require "state_contraption/version"
require "active_support/concern"

module StateContraption
  extend ActiveSupport::Concern

  module ClassMethods
    def validate_in_states(states)
      yield(StateSpecificValidator.new(self, states))
    end

    # Provides Class::GROUP_STATES constant, Class.group scope, instance.group? boolean
    def state_group(group, states)
      const_set "#{group.upcase}_STATES", states
      const_set "NOT_#{group.upcase}_STATES", const_get('STATES') - states
      scope group, where("#{table_name}.state IN (?)", states)
      scope "not_#{group}", where("#{table_name}.state NOT IN (?)", states)
      define_method :"#{group}?" do
        states.include?(state)
      end
    end
  end

  class StateSpecificValidator < Struct.new(:klass, :states)
    def method_missing(method, *args)
      # Things that don't share a signature with .validates don't want to be passed through here
      unless method =~ /^validate(s)?(_.*)?/
        raise "Method #{method} not whitelisted for StateValidator"
      end
      if args[-1].is_a? Hash
        options = args.pop.dup # We're going to modify it, be nice and dup
      else
        options = {}
      end
      original_if = options[:if]
      states = self.states
      options[:if] = ->(obj) do
        states.include?(obj.state) and (
        !original_if or original_if.call(obj)
        )
      end
      klass.send(method, *args, options)
    end
  end
end
