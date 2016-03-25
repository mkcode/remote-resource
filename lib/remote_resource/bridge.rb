require 'remote_resource/attribute_method_attacher'

module RemoteResource
  # Extending a class with the HasRemote::Bridge module will bring in
  # the has_remote and embed_remote method, and therefore all of the
  # functionality of the has_remote gem. In Rails, ActiveRecord is
  # automatically extended with Bridge, and you would use the has_remote call
  # like a familiar 'has_one' association method. Outside of Rails, or if used
  # in non ActiveRecord domain objects, extending your domain objects with
  # Bridge is how to setup has_remote on those classes.
  module Bridge
    # Public: Setup the provided remote resource on this class. This creates a
    # method on the class that returns the remote resource object that is
    # associated with that record. The method shares the name with the first
    # argument unless the `as` options is supplied to override this.
    #
    # which_class - A symbol representing a descendant class of
    #               HasRemote::Resource. The symbol is the underscored
    #               version of the class name.
    #                 Ex: (class) GithubUser => (symbol) :github_user
    # options     - A hash of options. (default: {}) Always use symbols for
    #               keys. These options are also passed to the
    #               AssociationBuilder and the AttributeMethodAttacher.
    #               :as             - a symbol that defines the method name that
    #                                 returns the association. By default, this
    #                                 is the same name as the first argument
    #                                 specifying the remote resource class.
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
    #                                 attribute defined on the resource. The
    #                                 values are the overriding name of the
    #                                 method.
    #
    # Examples
    #
    #   class Repo < ActiveRecord::Base
    #     has_remote :github_repo
    #
    #     ...
    #   end
    #
    #   The above `has_remote` call assumes that the following class
    #   exists:
    #
    #   class GithubRepo < HasRemote::Resource
    #     ...
    #     attribute :description
    #     ...
    #   end
    #
    #   There is now an instance method on Repo that will return that instances
    #   associated GithubRepo instance.
    #
    #   repo = Repo.find(1)
    #   repo.github_repo #=> <class GithubRepo instance >
    #   repo.github_repo.description #=> "A ruby gem for ruby gems."
    #
    #   as option:
    #
    #   has_remote :github_repo, as: :on_github
    #
    #   Specifying the 'as' option will override the created association method
    #   name. The method will now be 'on_github' rather than 'github_user'.
    #
    #   repo = Repo.find(1)
    #   repo.on_github #=> <class GithubRepo instance >
    #   repo.on_github.description #=> "A ruby gem for ruby gems."
    #
    #   scope option:
    #
    #   has_remote :github_user, scope: { id: :gh_user_id }
    #
    #   The scope hash in this example will evaluate the 'gh_user_id' method on
    #   this class and send it in as the :id on the scope Hash. This style scope
    #   argument is especially useful when the same remote resource class is
    #   mixed into multiple models, and therefore the multiple models are not
    #   forced to use the same method names for the scope values. The scope hash
    #   that is passed into the client and resource blocks will look like this:
    #   { id: 2345987 }
    #
    #   has_remote :github_user, scope: [:id, :access_token]
    #
    #   This scope array will evaluate both the :id and :access_token methods on
    #   this class. The scope hash that is passed into the client and resource
    #   blocks will look like this: { id: 274346, access_token: '2ac4g3t7jf8'}
    #
    #   has_remote :github_user, scope: :github_login
    #
    #   This will evaluate the :github_login method on this class. The scope
    #   hash that is passed into the client and resource blocks will look like
    #   this: { github_login: 'mkcode' }
    #
    #   prefix and attribute_map options:
    #
    #   has_remote :github_user, prefix: :gh_user
    #
    #   All of the attribute methods defined on the association will be prefixed
    #   with 'gh_user_'. If the Base attributes class defined attributes :login
    #   and :email, this class would have the methods: :gh_user_login and
    #   :gh_user_email.
    #
    #   has_remote :github_user, attributes_map: { email: :gh_email }
    #
    #   The attributes_map argument here will override the name of the :email
    #   attribute. Instead of the method being named :email, it will now be
    #   named :gh_email.
    #
    # Returns an instance of AssociationBuilder.
    def has_remote(which_klass, options = {})
      klass = RemoteResource::Base.find_descendant(which_klass)
      fail BaseClassNotFound.new(which_klass) unless klass

      builder = AssociationBuilder.new(klass, options)
      builder.associated_with(self)
    end

    # Public: embed_remote takes takes the exact same options as 'has_remote'
    # and completes the same behavior as well with one addition. It defines the
    # attribute getter methods directly on the target class, in addition to on
    # the association. This is similar in theory to the object oriented
    # programming 'is_a' vs 'has_a', inheritance vs composition debate. By
    # defining the attribute methods directly on the domain object, that domain
    # object 'is' a remote resource. Note that this will only define the
    # attribute getter methods on the target class. Additional methods defined
    # on the Resource class will not be copied, but may still be accessed
    # through the association method.
    #
    # Examples
    #
    #   class Repo < ActiveRecord::Base
    #     embed_remote :github_repo
    #
    #     ...
    #   end
    #
    #   class GithubRepo < HasRemote::Resource
    #     ...
    #     attribute :description
    #     ...
    #   end
    #
    #   repo = Repo.find(1)
    #   repo.github_repo #=> <class GithubRepo instance >
    #   repo.github_repo.description #=> "A ruby gem for ruby gems."
    #
    #   So far, this has been exactly the same as 'has_remote'. The addition:
    #
    #   repo.description #=> "A ruby gem for ruby gems."
    #
    #   Repo 'is' a GithubRepo.
    #
    # Returns nil
    def embed_remote(which_klass, options = {})
      assoc_builder = has_remote(which_klass, options)

      attacher = AttributeMethodAttacher.new(assoc_builder.base_class, options)
      attacher.attach_to(self, assoc_builder.options[:as].to_s)
    end
  end
end
