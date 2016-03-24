require 'api_cached_attributes/attribute_method_attacher'

module ApiCachedAttributes
  # Extending a class with the ApiCachedAttributes::Bridge module will bring in
  # the api_cached_atributes method, and therefore all of the functionality of
  # the ApiCachedAttributes gem. In Rails, ActiveRecord is automatically
  # extended with Bridge, and you would use the api_cached_attributes call like
  # a familiar 'acts_as' method. Outside of Rails, or if used non ActiveRecord
  # domain objects, extending your domain objects with Bridge is how to setup
  # ApiCachedAttributes on those classes.
  module Bridge
    # Public: Setup the provided api cached attributes on this class. This
    # creates a getter (and setter) method on the calling class for each
    # attribute defined in the referenced ApiCachedAttributes::Base class.
    #
    # which_class - A symbol representing a descendant class of
    #               ApiCachedAttributes::Base. The symbol is the underscored
    #               version of the class name minus the 'Attributes' suffix.
    #               Ex: (class) GithubUserAttributes => (symbol) :github_user
    # options     - A hash of options. (default: {}) Always use symbols for
    #               keys. These options are also passed into the MethodAttacher
    #               and then to the MethodResolver.
    #               :scope          - the scope option represents the context in
    #                                 which this api resource is unique. It has
    #                                 a similar meaning to ActiveRecord's
    #                                 meaning of scope, as opposed the API
    #                                 access meaning. The scope value can be a
    #                                 Symbol, Array, or Hash. It is used to
    #                                 build the scope argument, which is sent
    #                                 into the client and resource blocks on the
    #                                 Base attributes class. This argument to
    #                                 these blocks is always a hash, whose
    #                                 values were methods responses evaluated on
    #                                 the target_class.
    #               :prefix         - prefix for the names of the newly created
    #                                 methods.
    #               :attributes_map - A hash for overriding method names to
    #                                 create. The keys in this hash represent an
    #                                 attribute defined on the base_class. The
    #                                 values are the overriding name of the
    #                                 method to be defined on the target_class.
    #
    # Examples
    #
    #   class Repo < ActiveRecord::Base
    #     api_cached_attributes :github_repo
    #
    #     ...
    #   end
    #
    #   The above `api_cache_attributes` call assumes that the following class
    #   exists:
    #
    #   class GithubRepoAttributes < ApiCachedAttributes::Base
    #     ...
    #   end
    #
    #   scope option:
    #
    #   api_cached_attributes :github_user, scope: { id: :gh_user_id }
    #
    #   The scope hash in this example will evaluate the 'gh_user_id' method on
    #   this class and send it in as the :id on the scope Hash. This style scope
    #   argument is especially useful when the same attributes Base class is
    #   mixed into multiple models, and therefore the multiple models are not
    #   forced to use the same method names for the scope values. The scope hash
    #   that is passed into the client and resource blocks will look like this:
    #   { id: 2345987 }
    #
    #   api_cached_attributes :github_user, scope: [:id, :access_token]
    #
    #   This scope array will evaluate both the :id and :access_token methods on
    #   this class. The scope hash that is passed into the client and resource
    #   blocks will look like this: { id: 274346, access_token: '2ac4g3t7jf8'}
    #
    #   api_cached_attributes :github_user, scope: :github_login
    #
    #   This will evaluate the :github_login method on this class. The scope
    #   hash that is passed into the client and resource blocks will look like
    #   this: { github_login: 'mkcode' }
    #
    #   prefix and attribute_map options:
    #
    #   api_cached_attributes :github_user, prefix: :gh_user
    #
    #   All of the attribute methods defined on this class will be prefixed with
    #   'gh_user_'. If the Base attributes class defined attributes :login and
    #   :email, this class would have the methods: :gh_user_login and
    #   :gh_user_email.
    #
    #   api_cached_attributes :github_user, attributes_map: { email: :gh_email }
    #
    #   The attributes_map argument here will override the name of the :email
    #   attribute. Instead of the method being named :email, it will now be
    #   named :gh_email.
    #
    # returns nil
    def has_remote(which_klass, options = {})
      klass = ApiCachedAttributes::Base.find_descendant(which_klass)
      fail BaseClassNotFound.new(which_klass) unless klass

      builder = AssociationBuilder.new(klass, options)
      builder.associated_with(self)
    end

    def embed_remote(which_klass, options = {})
      klass = ApiCachedAttributes::Base.find_descendant(which_klass)
      fail BaseClassNotFound.new(which_klass) unless klass

      builder = AssociationBuilder.new(klass, options)
      builder.associated_with(self)

      attacher = AttributeMethodAttacher.new(klass, options)
      attacher.attach_to(self, builder.options[:as].to_s)
    end
  end
end
