#encoding:utf-8
require_relative 'http/request_agent'
require_relative 'element/element'
require_relative 'logger_out'
module AppClient
  #require http method, for requesting webdriverAgent

  class Driver

    include Http::RequestAgent
    include AppClient::Element
    include AppClient::LoggerOut

    attr_reader :server_url
    attr_reader :device
    attr_reader :browser_name
    attr_reader :sdk_version
    attr_reader :bundle_id
    attr_reader :session
    attr_reader :session_url
    attr_reader :element_id
    attr_reader :element_url

    #init to  WebDriverAgent runing succeed or not
    def initialize(server_url)
      #example http://192.168.2.97:8100
      @timeout = 10
      @duration=3
      @server_url = server_url
      # get /status
      agent = get(@server_url+'/status')

      fail 'WebDriver Agent running failed or server_url is wrong' if agent==nil
      fail 'WebDriver Agent running failed' if agent['status']!=0 || agent['sessionId']==0
      # set session
      @session = agent['sessionId']
      #example http://192.168.2.97:8100/session
      @session_url = @server_url+'/session/'+@session
      # Initialize log module
      @logger =AppClient::LoggerOut.logger
      @logger.info_log('AppClient::driver.init',"connect WebDriverAgent succeed\n")

      $driver = self
      self # return newly created driver
    end

    def start_device(opt={})
      fail 'opt must be a hash' unless opt.is_a? Hash

      app_info = opt[:desiredCapabilities]||{}

      @bundle_id = app_info.fetch(:bundle_id,false)

      start_resp=post(@server_url+'/session/',opt.to_json)
      #add catch exception
      if start_resp['status']!=0 || start_resp['sessionId']==0
        @logger.info_log('AppClient::driver.start_device',"app launch failed\n")
        fail 'app launch failed'
      end


      #app which tested infos
      @device = start_resp['value']['capabilities']['device']
      @browser_name = start_resp['value']['capabilities']['browserName']
      @sdk_version = start_resp['value']['capabilities']['sdkVersion']

      @logger.info_log('AppClient::driver.start_device',"the app launched successfully\n")
    end


    def deactivate_app(duration)
      opt={duration:duration}.to_json
      data=post(@session_url+'/deactivateApp',opt)
      p "deactivate_app: #{data}"

    end

    # using: key     =>'name'  'xpath' 'class'
    # value: value   => '登录'
    # opt={
    #   using: key
    #   value: value
    # }
    def find_element(opt = {})
      # get element id
      search_element(opt)
      #set element_url
      @element_url = "#{@session_url}/element/#{@element_id}"

      self
    end


    # operate: click element on page
    def click_element(opt = {})
      search_element(opt) if opt != {}
      # click @element_id
      url=@session_url + "/element/#{@element_id}/click"
      click=post(url,'')
      return click
    end

    # send value to textfield textarea
    def set_value(opt = {})
      fail 'the value must exists !' if opt == {}
      # click @element_id
      url=@session_url + "/element/#{@element_id}/value"
      click=post(url,opt.to_json)
      return click
    end



    # wait element to find click so
    def wait_element(opt = {})
      begin
        wait = Selenium::WebDriver::Wait.new(:timeout => @timeout)
        wait.until {
          # post(@session_url+'/element/',opt)['status'].equal?(0)
          search_element(opt).length.equal?(32)
        }
        return true
      rescue
        return false
      end
    end

  end
end