module Fluent
    class JsonbucketOutput < Fluent::Output
        Fluent::Plugin.register_output('jsonbucket', self)
        config_param :output_tag, :string, :default => nil
        config_param :json_key, :string, :default => 'json'
        config_param :force_encoding, :string, :default => nil

        def configure(conf)
            super
            unless config.has_key?('output_tag')
                raise Fluent::ConfigError, "you must set 'output_tag'"
            end
        end

        def emit(tag, es, chain)
            record = set_encoding(record) if @force_encoding
            es.each {|time,record|
                chain.next
                bucket = {@json_key => record.to_json}
                Fluent::Engine.emit(@output_tag, time, bucket)
            }
        end

        def set_encoding(record)
          record.each_pair { |k, v|
            if v.is_a?(String)
              v.force_encoding(@char_encoding)
            end
          }
        end

    end
end
