# encoding: utf-8
module Mongoid #:nodoc:
  module Fields #:nodoc:
    module Serializable #:nodoc:
      module ForeignKeys #:nodoc:

        # Defines the behaviour for array fields.
        class Array
          include Serializable

          # Get the default value for the field. If the default is a proc call
          # it, otherwise clone the array.
          #
          # @example Get the default.
          #   field.default
          #
          # @return [ Object ] The default value cloned.
          #
          # @since 2.1.0
          def default
            # default should return the proxied array.
            Proxy.new(metadata, default_value.dup)
          end

          # Serialize the object from the type defined in the model to a MongoDB
          # compatible object to store.
          #
          # @example Serialize the field.
          #   field.serialize(object)
          #
          # @param [ Object ] object The object to cast.
          # @param [ Document ] document The document that made the method call.
          #
          # @return [ Proxy::Array ] The proxied array.
          #
          # @since 2.1.0
          def serialize(object, document = nil)
            # Wrap the object in the proxied array.
            object.blank? ? [] : constraint.convert(object)
          end

          # Deserialize the field.
          #
          # @example Deserialize the array.
          #   field.deserialize(object)
          #
          # @param [ Object ] object The object to deserialize.
          # @param [ Document ] document The caller.
          #
          # @return [ Proxy::Array ] The proxied array.
          #
          # @since 2.1.0
          def deserialize(object, document = nil)
            # deserialize should be implemented to return the proxied array.
            object
          end

          protected

          # Get the constraint from the metadata once.
          #
          # @example Get the constraint.
          #   field.constraint
          #
          # @return [ Constraint ] The relation's contraint.
          #
          # @since 2.1.0
          def constraint
            @constraint ||= metadata.constraint
          end

          # The proxy class wraps the foreign key array and performs the
          # necessary inverse operations when the array is appended to or an
          # item is deleted.
          class Proxy < ::Array

            # Instantiate a new proxy.
            #
            # @example Create the new proxy.
            #   Array::Proxy.new(metadata)
            #
            # @param [ Metadata ] metadata The relation metadata.
            # @param [ Array ] array The array to wrap.
            #
            # @since 2.1.0
            def initialize(metadata, array)
              @metadata = metadata
              super(array)
            end
          end
        end
      end
    end
  end
end
