require 'sinatra/base'
require 'sinatra/json'
require 'aws-sdk'

module CentralReg
  module Routes
    module DNS

      def self.registered(app)
        app.get '/ping' do
          json :status => 'pong'
        end

        app.get '/status' do
          request_body = request.body.read
          puts request_body
          if request_body == ''
            hosted_zone_name = nil
          else
            puts "parsing json"
            payload = JSON.parse(request_body, :symbolize_names => true)
            hosted_zone_name = payload[:hosted_zone]
          end

          rt53 = Aws::Route53::Client.new(region: 'us-east-1')

          # No way to get a zone by name, only ID. List all zones, starting
          # lexicographically at the one we want and check that we got the
          # zone we expected.
          zones = rt53.list_hosted_zones_by_name(dns_name: hosted_zone_name,
                                                max_items: 1)

          unless hosted_zone_name.nil?
            if zones.hosted_zones.length == 1 && zones.hosted_zones[0].name == "#{hosted_zone_name}."
              json :status => 'OK'
            else
              status 400
              json :status => 'FAILURE'
            end
          else
            hosted_zone_list = rt53.list_hosted_zones
            if hosted_zone_list.length >= 1
              json :status => 'OK'
            else
              status 400
              json :status => 'FAILURE'
            end
          end
        end

        app.put '/record' do
          payload = JSON.parse(request.body.read, :symbolize_names => true)
          hosted_zone_name = payload[:hosted_zone]
          resource_record_set = payload[:resource_record_set]

          puts hosted_zone_name
          #puts resource_record_set

          rt53 = Aws::Route53::Client.new(region: 'us-east-1')

          # Get our hosted zone ID.
          zones = rt53.list_hosted_zones_by_name(dns_name: hosted_zone_name,
                                                max_items: 1)
          if zones.hosted_zones.length == 1 && zones.hosted_zones[0].name == "#{hosted_zone_name}."
            hosted_zone_id = zones.hosted_zones[0].id
            puts hosted_zone_id
          else
            status 400
            halt json :status => 'FAULURE', :reason => "unknown zone #{hosted_zone_name}"
          end

          rt53.change_resource_record_sets(
            {
              :hosted_zone_id => hosted_zone_id,
              :change_batch => {
                :changes => [
                  {
                    :action => 'CREATE',
                    :resource_record_set => resource_record_set
                  }
                ]
              }
            }
          )
        end
      end
    end
  end
end
