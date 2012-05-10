module RightScaleAPI
  class ServerTemplate <  Account::SubResource
    attributes %w(
      nickname
      description
      parameters
      is_head_version
      version
      href
      updated_at
    )
    
    def self.api_name
      'ec2_server_template'
    end
    
    def collection_uri
      account.path+"/server_templates"
    end
    
    def right_scripts
      get('/executables.xml')['server_template_executables'].find_all { |attrs| attrs['right_script'] }.map do |attrs|
        RightScript.new(attrs['right_script']) if attrs['right_script']
      end
    end
  end
end
