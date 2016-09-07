module EveOnline
  module Characters
    # https://eveonline-third-party-documentation.readthedocs.org/en/latest/xmlapi/character/char_upcomingcalendarevents.html
    class UpcomingCalendarEvents < BaseXML
      API_ENDPOINT = 'https://api.eveonline.com/char/UpcomingCalendarEvents.xml.aspx'.freeze

      ACCESS_MASK = 1_048_576

      attr_reader :key_id, :v_code, :character_id

      def initialize(key_id, v_code, character_id)
        super()
        @key_id = key_id
        @v_code = v_code
        @character_id = character_id
      end

      # TODO: memoize
      def events
        case row
        when Hash
          [Event.new(row)]
        when Array
          output = []
          row.each do |event|
            output << Event.new(event)
          end
          output
        else
          raise ArgumentError
        end
      end

      def url
        "#{ API_ENDPOINT }?keyID=#{ key_id }&vCode=#{ v_code }&characterID=#{ character_id }"
      end

      private

      def rowset
        result.fetch('rowset')
      end
      memoize :rowset

      def row
        rowset.fetch('row')
      end
      memoize :row
    end
  end
end
