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
          # @param [ Document ] document The base document.
          #
          # @return [ Object ] The default value cloned.
          #
          # @since 2.1.0
          def default(document = nil)
            Proxy.new(document, metadata, name, default_value.dup)
          end

          # Read this object from the attributes hash, and convert it to a
          # proxy if necessary.
          #
          # @example Deserialize the field.
          #   field.deserialize([], model)
          #
          # @param [ Object ] object The object to cast.
          # @param [ Document ] document The document making the method call.
          #
          # @return [ Proxy ] The proxied array.
          #
          # @since 2.1.0
          def deserialize(object, document = nil)
            return object if object.is_a?(Proxy)
            Proxy.new(document, metadata, name, object)
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
          # @return [ Proxy ] The proxied array.
          #
          # @since 2.1.0
          def serialize(object, document = nil)
            value = object.blank? ? [] : constraint.convert(object)
            Proxy.new(document, metadata, name, value).tap do |proxy|
              proxy.substitute!
            end
          end

          private

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
        end
      end
    end
  end
end
