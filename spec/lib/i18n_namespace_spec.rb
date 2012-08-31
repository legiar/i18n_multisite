require "spec_helper"
require "i18n"
require "i18n_namespace"
require "active_support/core_ext/hash"

describe I18n do

  before :all do
    I18n::Backend::Simple.send :include, ::I18nNamespace::Storing
    I18n::Backend::Simple.send :include, ::I18nNamespace::Fallbacks
    I18n.backend = I18n::Backend::Simple.new()
  end

  before :each do
    I18n.namespace = nil
    I18n.reload!
  end

  describe "config" do

    it "should has read accessor 'namespace'" do
      I18n.config.should respond_to(:namespace)
    end

    it "should has write accessor 'namespace='" do
      I18n.config.should respond_to('namespace=')
    end

    it "should has helper 'namespace'" do
      I18n.should respond_to(:namespace)
    end

    it "should has helper 'namespace='" do
      I18n.should respond_to('namespace=')
    end

    it "should has set namespace" do
      I18n.namespace = :salesman
      I18n.namespace.should eq :salesman
    end

    describe "validation" do
      it "should raise if namespace array includes none supported objects" do
        lambda { I18n.namespace = [ :salesman, nil ]        }.should raise_error
        lambda { I18n.namespace = [ :salesman, "" ]         }.should raise_error

        lambda { I18n.namespace = [ :salesman, Proc.new{} ] }.should raise_error
        lambda { I18n.namespace = [ :salesman, Array.new ]  }.should raise_error
        lambda { I18n.namespace = [ :salesman, Hash.new ]   }.should raise_error
      end

      it "should only accept String, Symbol, Array or NilClass" do
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

  end

  describe "storing" do

    def t(key, options = {})
      options.reverse_merge!(:namespaced => false)
      I18n.t key, options
    end

    def s(data, options = {})
      options.reverse_merge!(:escape => false, :namespaced => true)
      I18n.backend.store_translations I18n.locale, data, options
    end

    def sr(key, value)
      I18n.store_resolved_translation I18n.locale, key, value, :escape => false, :namespaced => true
    end

    it "should resolve dot separated key to hash" do
      sr("foo.bar.title", "FooBar")
      t("foo.bar.title").should eq "FooBar"
    end

    it "should save with namespace" do
      I18n.namespace = :salesman

      s(:title => "Willkommen")
      t("salesman.title").should eq "Willkommen"

      I18n.namespace = [:salesman, :club]

      s(:title => "Willkommen")
      t("salesman.club.title").should eq 'Willkommen'
    end

    it "should not save with namespace" do
      options = { :namespaced => false }

      I18n.namespace = :salesman

      s({:title => "Willkommen"}, options)
      t("salesman.title").should include("translation missing")

      I18n.namespace = [:salesman, :club]

      s({:title => "Willkommen"}, options)
      t("salesman.club.title").should include("translation missing")
    end

  end

  describe "namespace fallbacks" do

    before(:each) do
      @salesman_title = "Willkommen Salesman"
      @club_title     = "Willkommen im Club"
      @title          = "Willkommen"

      store_translations({
        :title    => @title,
        :salesman => {
          :title => @salesman_title,
          :club  => {
            :title => @club_title
          }
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

    describe "with no namespace" do

      it "should return title" do
        t("title").should == @title
      end

      it "should show translation missing" do
        t("foobar").should include("translation missing")
      end

    end

    describe "with namespace" do

      it "should not fallback" do
        I18n.namespace = :salesman
        t("title").should == @salesman_title

        I18n.namespace = [:salesman, :club]
        t("title").should == @club_title
      end

      it "should fallback" do
        I18n.namespace = [:salesman, :user]
        t("title").should == @salesman_title

        I18n.namespace = [:community, :user, "23051949"]
        t("title").should == @title
      end

      it "should show translation missing" do
        I18n.namespace = :salesman
        t("foobar").should include("translation missing")
      end
    end
  
  end

  describe "with scope" do

    before :each do
      @message      = "Base Message"
      @site_message = "Message for site"


      I18n.backend.store_translations(I18n.locale, {
        :activerecord => {
          :errors => {
            :messages => {
              :record_invalid => @message
            }
          }
        },
        :site => {
          :activerecord => {
            :errors => {
              :messages => {
                :record_invalid => @site_message
              }
            }
          }
        }
      })
    end

    it "should get base message" do
      I18n.namespace = nil
      I18n.t(:record_invalid, :namespaced => true, :scope => [:activerecord, :errors, :messages]).should eq @message
    end

    it "should get scoped message" do
      I18n.namespace = :site
      I18n.t(:record_invalid, :namespaced => true, :scope => [:activerecord, :errors, :messages]).should eq @site_message
    end

    it "should get base message for fallback" do
      I18n.namespace = :new_site
      I18n.t(:record_invalid, :namespaced => true, :scope => [:activerecord, :errors, :messages]).should eq @message
    end

  end

  describe "with defaults" do
    
    # Class Admin < User
    # end
    #
    # Admin.human_attribute_name(:name)
    # try to find key: "activerecord.attributes.admin.name"
    # with defaults: 
    # "activerecord.attributes.user.name"
    # "attributes.name"
    # "name"
    before :each do
      @admin_name       = "Admin Name"
      @user_title       = "User Title"
      @user_name        = "User Name"

      I18n.backend.store_translations(I18n.locale, {
        :activerecord => {
          :attributes => {
            :admin => {
              :name => @admin_name
            },
            :user => {
              :title => @user_title
            }
          }
        },
        :site => {
          :activerecord => {
            :attributes => {
              :user => {
                :name => @user_name
              }
            }
          }
        }
      })

      @name_default = [:"activerecord.attributes.user.name", :"attributes.name", :"name"]
      @title_default = [:"activerecord.attributes.user.title", :"attributes.title", :"title"]
      @name_key = "activerecord.attributes.admin.name"
      @title_key = "activerecord.attributes.admin.title"
    end

    it "should get base message" do
      I18n.namespace = nil
      I18n.t(@name_key, :namespaced => true, :default => @name_default).should eq @admin_name
    end

    it "should get message from defaults" do
      I18n.namespace = nil
      I18n.t(@title_key, :namespaced => true, :default => @title_default, :count => 1).should eq @user_title
    end

    it "should get namespaced message from defaults" do
      I18n.namespace = :site
      I18n.t(@name_key, :namespaced => true, :default => @name_default, :count => 1).should eq @user_name
    end

    it "should get fallback message from defaults" do
      I18n.namespace = :site
      I18n.t(@title_key, :namespaced => true, :default => @title_default, :count => 1).should eq @user_title
    end

  end

end

