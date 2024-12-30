module Boards
  class ConnectorFactory
    CONNECTORS = {
      'indeed' => IndeedConnector,
      'linkedin' => LinkedInConnector
    }.freeze

    def self.build(board_name)
      connector_class = CONNECTORS[board_name.downcase]
      raise ArgumentError, "Unknown board: #{board_name}" unless connector_class

      connector_class.new
    end
  end
end
