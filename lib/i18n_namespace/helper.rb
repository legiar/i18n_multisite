module I18nNamespace
  module Helper
    private

    # save converting to array, :symbol doesn't response to method to_a
    def to_a(o)
      return o.dup if o.is_a? Array
      [o]
    end
  end
end
