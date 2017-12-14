module EveOnline
  module ESI
    class CorporationBlueprints < Base
      API_ENDPOINT = 'https://esi.tech.ccp.is/v1/corporations/%s/blueprints/?datasource=tranquility&page=1'.freeze

      attr_reader :corporation_id

      def initialize(options)
        super

        @corporation_id = options[:corporation_id]
      end

      def blueprints
        output = []
        response.each do |blueprint|
          output << Models::Blueprint.new(blueprint)
        end
        output
      end
      memoize :blueprints

      def scope
        'esi-corporations.read_blueprints.v1'
      end

      def url
        API_ENDPOINT % corporation_id
      end
    end
  end
end