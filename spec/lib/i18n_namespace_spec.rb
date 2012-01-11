require 'yajl/json_gem'
require 'rspec'
require 'i18n'
require 'i18n_namespace'
require 'active_support/core_ext/hash'

describe 'I18n' do
  before(:all) do
    @i18n_backend_saved = I18n.backend
  end

  after(:all) do
    I18n.backend = @i18n_backend_saved
  end

  def set_new_backend
    I18n.backend = I18nNamespace::KeyValue.new({})
  end

  describe 'with backend chain' do
    before(:each) do
      I18n.backend = I18n::Backend::Simple.new
      I18n.backend.store_translations I18n.locale, {:foo => {:bar => {:title => 'foo bar'}}}, :escape => false

      I18n.backend = I18n::Backend::Chain.new(I18nNamespace::KeyValue.new({}), I18n.backend)
      I18n.backend.store_translations I18n.locale, {:title => 'Willkommen'}, :escape => false
    end

    it 'should fallback with the backend chain' do
      I18n.t('foo.bar.title').should == 'foo bar'
    end
  end

  describe 'storing' do
    before(:each) do
      set_new_backend
    end

    def t(key, options = {})
      options.reverse_merge!(:namespaced => false)
      I18n.t key, options
    end

    def s(data, options = {})
      options.reverse_merge!(:namespaced => true, :escape => false)

      I18n.backend.store_translations I18n.locale, data, options
    end

    def sr(key, value)
      I18n.store_resolved_translation I18n.locale, key, value, :escape => false, :namespaced => true
    end


    it 'should resolve dot separated key to hash' do
      sr('foo.bar.title', 'FooBar')
      t('foo.bar.title').should == 'FooBar'
    end

    it 'should save with namespace' do
      I18n.namespace = :salesman

      s('title' => 'Willkommen')
      t('salesman.title').should == 'Willkommen'

      I18n.namespace = [ :salesman, :club ]

      s('title' => 'Willkommen')
      t('salesman.club.title').should == 'Willkommen'
    end

    it 'should not save with namespace' do
      options = { :namespaced => false }

      I18n.namespace = :salesman

      s({'title' => 'Willkommen'}, options)
      t('salesman.title').should include('translation missing')

      I18n.namespace = [:salesman, :club]

      s({'title' => 'Willkommen'}, options)
      t('salesman.club.title').should include('translation missing')
    end
  end

  describe 'validation' do
    it 'should raise if namespace array includes none supported objects' do
      lambda { I18n.namespace = [ :salesman, nil ]        }.should raise_error
      lambda { I18n.namespace = [ :salesman, "" ]         }.should raise_error

      lambda { I18n.namespace = [ :salesman, Proc.new{} ] }.should raise_error
      lambda { I18n.namespace = [ :salesman, Array.new ]  }.should raise_error
      lambda { I18n.namespace = [ :salesman, Hash.new ]   }.should raise_error
    end

    it 'should only accept String, Symbol, Array or NilClass' do
      I18n.namespace = :symbol
      I18n.namespace.should == :symbol

      I18n.namespace = "string"
      I18n.namespace.should == "string"

      I18n.namespace = nil
      I18n.namespace.should == nil

      I18n.namespace = []
      I18n.namespace.should == []
    end
  end

  describe 'namespace fallbacks' do
    before(:each) do
      set_new_backend

      @salesman_title = 'Willkommen Salesman'
      @club_title     = 'Willkommen im Club'
      @title          = 'Willkommen'

      store_translations(
        { :title    => @title,
          :salesman => { :title => @salesman_title,
            :club => { :title => @club_title }
      }
      })
    end

    def store_translations(*args)
      case args.count
      when 1
        raise "Your argument isn't a Hash" unless args.first.is_a? Hash
        data = args.shift
      when 2
        data = { args.shift => args.shift }
      end

      I18n.backend.store_translations I18n.locale, data
    end

    def t(key, options = {})
      options.reverse_merge!(:namespaced => true)

      I18n.t key, options
    end

    describe 'with no namespace' do
      before(:each) do
        I18n.namespace = nil
      end

      it 'should return title' do
        t('title').should == @title
      end

      it 'should show translation missing' do
        t('foobar').should include('translation missing:')
      end
    end

    describe 'with namespace' do
      before(:each) do
        I18n.namespace = :salesman
      end

      it 'should not fallback' do
        I18n.namespace = :salesman
        t('title').should == @salesman_title

        I18n.namespace = [:salesman, :club]
        t('title').should == @club_title
      end

      it 'should fallback' do
        I18n.namespace = [:salesman, :user]
        t('title').should == @salesman_title

        I18n.namespace = [:community, :user, '23051949']
        t('title').should == @title
      end

      it 'should show translation missing' do
        t('foobar').should include('translation missing')
      end
    end

  end
end

