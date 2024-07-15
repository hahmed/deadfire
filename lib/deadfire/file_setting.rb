frozen_string_literal: true

module Deadfire
  class FileSetting
    attr_reader :filename, :refresh_option

    ALL_REFRESH_OPTIONS = %i[none all self].freeze

    def initialize(filename, refresh_option: :self)
      @filename = filename
      @refresh_option = validate_refresh_option(refresh_option)
    end

    private

    def validate_refresh_option(refresh_option)
      unless ALL_REFRESH_OPTIONS.include?(refresh_option)
        raise ArgumentError.new("Invalid refresh option #{refresh_option}")
      end

      refresh_option
    end
  end
end