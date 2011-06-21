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
            value = object.blank? ? [] : constraint.convert(object)
            Proxy.new(document, metadata, name, value)
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

            attr_reader :base, :metadata, :name

            # When appending an object to this array, we need to append the
            # base key to the inverse side. We do this my performing an atomic
            # $addToSet on the document on the other side with the provided key
            # and the base document.
            #
            # @todo Durran: I don't like any of this code, probably because I
            #  don't like many-to-many relationships in object mappers. But
            #  this is the best I could think of right now.
            #
            # @note This will perform 2 atomic database calls to update the
            #   foreign keys on either side in order to keep the database in a
            #   consistent state.
            #
            # @example Add to the array.
            #   proxy << object_id
            #
            # @param [ Object ] object The id of the document getting added.
            #
            # @since 2.1.0
            def <<(object)
              if base.persisted?
                # Perform the atomic $addToSet for the inverse.
                execute(
                  "$addToSet",
                  metadata.klass.collection,
                  object,
                  metadata.inverse_foreign_key,
                  base.id
                )
                # Perform the atomic $addToSet for the base. This must persist
                # as well to keep the database in a consistent state.
                execute(
                  "$addToSet",
                  metadata.inverse_klass.collection,
                  base.id,
                  metadata.foreign_key,
                  object
                )
                # We remove the dirty foreign key now since it was
                # persisted.
                base.reset_attribute!(name)
              end
              super(object)
            end
            alias :push :<<

            # When deleting a key from this special array we need to remove the
            # base key from the inverse side in the database as well.
            #
            # @note This will perform 2 atomic database calls to update the
            #   foreign keys on either side in order to keep the database in a
            #   consistent state.
            #
            # @example Delete from the array.
            #   proxy.delete(object_id)
            #
            # @param [ Object ] object The id of the document getting deleted.
            #
            # @since 2.1.0
            def delete(object)
              if base.persisted?
                # Perform the atomic $pull for the inverse.
                execute(
                  "$pull",
                  metadata.klass.collection,
                  object,
                  metadata.inverse_foreign_key,
                  base.id
                )
                # Perform the atomic $pull for the base. This must persist
                # as well to keep the database in a consistent state.
                execute(
                  "$pull",
                  metadata.inverse_klass.collection,
                  base.id,
                  metadata.foreign_key,
                  object
                )
                # We remove the dirty foreign key now since it was
                # persisted.
                base.reset_attribute!(name)
              end
              super(object)
            end

            # Instantiate a new proxy.
            #
            # @example Create the new proxy.
            #   Array::Proxy.new(metadata)
            #
            # @param [ Metadata ] metadata The relation metadata.
            # @param [ Object ] object The object or array to wrap.
            #
            # @since 2.1.0
            def initialize(base, metadata, name, object)
              @base, @metadata, @name = base, metadata, name
              super(object)
            end

            private

            # Perform an atomic execution.
            #
            # @example Execute the atomic operation.
            #   array.execute("$pull", collection, id, "person_ids", inverse.id)
            #
            # @param [ String ] operation The atomic operation to perform.
            # @param [ Collection ] collection The document collection.
            # @param [ Object ] id The id of the document to update.
            # @param [ String ] key The name of the foreign key field.
            # @param [ Object ] inverse_id The id of the inverse document.
            #
            # @since 2.1.0
            def execute(operation, collection, id, key, inverse_id)
              collection.update({ :_id => id }, { operation => { key => inverse_id }})
            end
          end
        end
      end
    end
  end
end
