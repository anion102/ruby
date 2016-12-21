#encoding:utf-8
#author:kanlijun
require 'selenium-webdriver'
module AppClient
  module Element
    DELAY_TIME = 3

    def search_element(opt)
      fail 'the request params opt can not be empty' if opt == {}
      # try 2 times to request search api
      for i in 0..1
        element= post(session_url+'/element/',opt.to_json)
        if element==nil||element.match(/.*/)
          sleep DELAY_TIME
          next
        end
        if element['status']==0&&element['value']['ELEMENT']!=''
          break
        else
          sleep DELAY_TIME
        end
      end
      # catch exception
      fail 'request search element api failed' if element==nil

      fail 'find the element failed' if element['status']!=0
      fail 'unable to find the element on page' if element['value']['ELEMENT']==''||element['value']['ELEMENT']==nil
      # get element_id
      @element_id = element['value']['ELEMENT']
      return @element_id

    end


    def search_sub(opt)
      # try 3 times to request search api
      for i in 0..1
        element= post(session_url+"/element/#{@element_id}/element",opt)
        if element==nil||element.match(/.*/)
          sleep DELAY_TIME
          next
        end
        if element['status']==0&&element['value']['ELEMENT']!=''
          break
        else
          sleep DELAY_TIME
        end
      end
      # catch exception
      fail 'request search element api failed' if element==nil

      fail 'find the sub element failed' if element['status']!=0
      fail 'unable to find the element sub on page' if element['value']['ELEMENT']==''||element['value']['ELEMENT']==nil
      # get element_id
      p element
=begin
      @element_id = element['value']['ELEMENT']
      return @element_id
=end
    end

  end
end