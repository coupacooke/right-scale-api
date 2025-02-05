module RightScaleAPI
  class Base
    
    # attributes that directly correspond to the api's
    # @param [Array<Symbol>] attrs a list of attributes an object type has
    def self.attributes attrs=nil
      if attrs
        @attributes ||= Base.attributes
        @attributes ||= []
        @attributes += attrs.map {|attr|attr.to_sym}
        attr_accessor *attrs

        attrs.each do |attr|
          if attr =~ /(.+)_href$/
            relation = $1
            attr_accessor relation
          end
        end

      end
      @attributes
    end
    
    attributes [:id, :href, :tags, :created_at, :updated_at,:errors, :nickname, :proxy_host, :proxy_port]

    # gets an object by id
    # @param id [Fixnum]
    def self.get id, opts={}
      new({:id => id}.merge(opts))
    end
    
    # creates a new object on RightScale
    # @param opts [Hash] attributes of the created object
    def self.create opts
      object_opts = opts.reject{|k,v| ! method_defined? "#{k}="}
      object = new object_opts
      query_opts = opts_to_query_opts opts

      result = RightScaleAPI::Client.post(object.collection_uri, :body => query_opts)
      
      if result.code.to_i != 201
        p object.collection_uri
        p query_opts
        p result.code
        p result.headers
        puts result.inspect
        raise "create failed"
      end

      new object_opts.merge(result.merge(:href =>  result.headers['location']))
    end  

    # The RightScale API name for the class
    def self.api_name
      name.demodulize.underscore
    end
    
    def initialize attributes
      attributes.each do |attr,value|
        send "#{attr}=", value
      end
      
      unless id
        self.id = id_from_href href if href
      end
    end
    
    def resource(result)
      if result.code.to_i != 201
        p result.code
        p result.headers
        puts result.inspect
        raise "create failed"
      end

      self.class.get(id_from_href(result.headers['location']), :account => account)
    end
    
    # Updates the object with the passed attributes
    # @param [Hash] attrs the updated attributes
    def update attrs
      put '', :body => {self.class.api_name =>  self.class.opts_to_query_opts(attrs)}
    end
    
    # tells the API to delete the object
    def destroy
      delete ''
    end

    def send_request method, *args
      args[0] = "#{path}#{args[0]}"
      RightScaleAPI::Client.send method, *args
    end

    def get *args
      send_request :get, *args
    end

    def head *args
      send_request :head, *args
    end

    def post *args
      send_request :post, *args
    end

    def put *args
      send_request :put, *args
    end

    def delete *args
      send_request :delete, *args
    end
    
    # the objects uri on rightscale
    def uri
      RightScaleAPI::Client.base_uri + path
    end

    # Reload the attributes of the object
    def reload!
      get('')[self.class.api_name].each do |attr, value|
        self.send :"#{attr}=",value
      end
    end

    def collection_uri
      self.class.collection_uri
    end
    
    def path
      "#{collection_uri}/#{id}"
    end

    protected
    
    def self.collection_uri uri=nil
      if uri
        @collection_uri= uri
      end
      @collection_uri
    end
    
    
    def id_from_href href
      href.split('/').last
    end
    
    def path_from_href href
      URI.parse(href).path
    end

    def self.opts_to_query_opts opts
      query_opts = opts.dup
      
      if query_opts[:region]
        val = query_opts.delete :region
        query_opts[:cloud_id] = RightScaleAPI::CLOUD_REGIONS[val.to_sym]
      end
      
      relations = attributes.select {|a|a.to_s.include? '_href'}
      relations.each do |r|
        r_name = r.to_s.sub('_href','').to_sym
        if query_opts[r_name]
          query_opts[r] = query_opts.delete(r_name).href
        end
      end

      attrs = query_opts.dup.delete_if {|k,v| ! attributes.include? k.to_sym }
      query_opts.dup.delete_if {|k,v| attributes.include? k.to_sym }

      query_opts[api_name] = attrs

      query_opts
    end
  end
end
