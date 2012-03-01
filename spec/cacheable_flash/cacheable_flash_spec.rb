require 'spec_helper'

describe 'CacheableFlash' do
  attr_reader :controller_class, :controller, :cookies
  before do
    @controller_class = Struct.new(:cookies, :flash)
    @controller_class.stub(:around_filter)
    @controller_class.send(:include, CacheableFlash)
    @controller = @controller_class.new({}, {})
    @cookies = {}
<<<<<<< HEAD
    @controller.stub(:cookies).and_return {@cookies}
=======
    @controller.stub(:cookies).and_return(@cookies)
>>>>>>> pboling/master
  end

  describe "#write_flash_to_cookie" do
    context "when there is not an existing flash cookie" do
      it "sets the flash cookie with a JSON representation of the Hash" do
        expected_flash = {
          'errors' => "This is an Error",
          'notice' => "This is a Notice"
        }
        controller.flash = expected_flash.dup
        controller.write_flash_to_cookie

        JSON(@controller.cookies['flash']).should == expected_flash
      end
    end

    context "when there is an existing flash cookie" do
      context "when the flash cookie is valid json" do
        it "appends new data to existing flash cookie" do
          @cookies['flash'] = {
            'notice' => "Existing notice",
            'errors' => "Existing errors",
          }.to_json

          @controller.flash = {
            'notice' => 'New notice',
            'errors' => 'New errors',
          }

          @controller.write_flash_to_cookie

          expected_flash = {
            'notice' => "Existing notice<br/>New notice",
            'errors' => "Existing errors<br/>New errors",
          }
          JSON(@controller.cookies['flash']).should == expected_flash
        end
      end

      context "when the flash cookie is 'invalid' json" do
        it "does not have an error and starts with an empty Hash" do
          @cookies['flash'] = ""
          lambda do
            JSON(@cookies['flash'])
          end.should raise_error(JSON::ParserError)

          @controller.write_flash_to_cookie

          JSON(@cookies['flash']).should == {}
        end
      end
    end
    
    it "converts flash value to string before storing in cookie if value is a number" do
      @controller.flash = { 'quantity' => 5 }
      @controller.write_flash_to_cookie
      JSON(@controller.cookies['flash']).should == { 'quantity' => "5" }
    end
    
    it "does not convert flash value to string before storing in cookie if value is anything other than a number" do
      @controller.flash = { 'foo' => { 'bar' => 'baz' } }
      @controller.write_flash_to_cookie
      JSON(@controller.cookies['flash']).should == { 'foo' => { 'bar' => 'baz' } }
    end
    
    it "encodes plus signs in generated JSON before storing in cookie" do
      @controller.flash = { 'notice' => 'Life, Love + Liberty' }
      @controller.write_flash_to_cookie
#      puts "JSON::VERSION: #{JSON::VERSION}, #{JSON::VERSION >= "1.6"}"
#      if JSON::VERSION >= "1.6"
        @controller.cookies['flash'].should == "{\"notice\":\"Life, Love %2B Liberty\"}"
#      else
#        @controller.cookies['flash'].should == "{\"notice\": \"Life, Love %2B Liberty\"}"
#      end
    end

    it "clears the controller.flash hash provided by Rails" do
      flash = {
        'errors' => "This is an Error",
        'notice' => "This is a Notice"
      }
      @controller.flash = flash
      @controller.write_flash_to_cookie

      @controller.flash.should == {}
    end
  end

  describe ".included" do
    it "sets the around_filter on the controller to call #write_flash_to_cookie" do
      @controller_class.should_receive(:around_filter).with(:write_flash_to_cookie)
      @controller_class.send(:include, CacheableFlash)
    end
  end
end
