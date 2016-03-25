require 'active_support/core_ext/string/strip'

module RemoteResource
  class Error < StandardError; end

  class ApiReadOnlyMethod < Error
    def initialize(method_name)
      @method_name = method_name
      super(message)
    end

    def message
      <<-MESSAGE.strip_heredoc

        The `RemoteResource` gem creates read only methods which represent
        API values. `#{@method_name}` was defined using this gem and this error
        is raised to indicate that these attributes are read only, although you
        may override this behavior by defining a `#{@method_name}=` setter
        method on this class.
      MESSAGE
    end
  end

  class BaseClassNotFound < Error
    def initialize(which_klass)
      @which_klass = which_klass
      super(message)
    end

    def message
      <<-MESSAGE.strip_heredoc

        A RemoteResource::Base class descendant named `#{@which_klass}`
        could not be found. Descendant class names are generally suffixed with
        'Attributes' and looked up without the attributes symbol. Example: A
        base class named 'GithubUserAttributes' is looked up with :github_user.
      MESSAGE
    end
  end
end
