module Rave
  module Mixins
    # Abstract object that allows you to create instances of the classes inside
    # it based on providing a type name.
    module ObjectFactory
      def self.included(base)
        @@classes = {}
        
        # Object factory method.
        #
        # :type - Type of object to create [String]
        #
        # === Options
        # As appropriate to the generated classes (options passed to constructor).
        def base.create(type, options = {})
          raise ArgumentError.new("Unknown #{self} type #{type}") unless @@classes[type]

          @@classes[type].new(options)
        end

        # Is this type able to be created?
        def base.valid_type?(type)
          @@classes.has_key? type
        end

        # Register this class with the factory.
        def base.factory_register
          @@classes[self::TYPE] = self
        end

        # Classes that can be generated by the factory [Array of Class]
        def base.classes
          @@classes.values
        end

        # Types that can be generated by the factory [Array of String]
        def base.types
          @@classes.keys
        end
      end

      # Type name for this class [String]
      attr_reader :type
      def type # :nodoc:
        self.class::TYPE.dup
      end
    end
  end
end
