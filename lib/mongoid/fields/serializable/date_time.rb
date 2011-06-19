# encoding: utf-8
module Mongoid #:nodoc:
  module Fields #:nodoc:
    module Serializable #:nodoc:

      # Defines the behaviour for date time fields.
      class DateTime
        include Serializable
        include Timekeeping

        # Deserialize this field from the type stored in MongoDB to the type
        # defined on the model.
        #
        # @example Deserialize the field.
        #   field.deserialize(object)
        #
        # @param [ Object ] object The object to cast.
        # @param [ Document ] document The document that made the method call.
        #
        # @return [ DateTime ] The converted date time.
        #
        # @since 2.1.0
        def deserialize(object, document = nil)
          object.try(:to_datetime)
        end
      end
    end
  end
end
