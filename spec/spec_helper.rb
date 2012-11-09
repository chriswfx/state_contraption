require 'state_contraption'
require 'active_record'

# Cribbed from http://iain.nl/testing-activerecord-in-isolation
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

# Fluid units used in example class
class Numeric
  def ounces
    self # Ounces is the base unit; if this wasn't just a test maybe we'd want a special fluid class
  end
  alias :ounce :ounces

  def pints
    self*16.ounces
  end
  alias :pint :pints

  def sips
    # Source: http://www.wired.com/wiredscience/2011/11/how-many-sips-in-a-bottle-of-beer/
    self*1.6.ounces
  end
  alias :sip :sips
end


