require File.join(File.dirname(__FILE__), 'spec_helper')

ActiveRecord::Migration.create_table :beer_contraptions do |t|
  t.string    :state
  t.integer   :beer_level
  t.integer   :capacity,    default: 1.pint
  t.boolean   :paid_for,    default: false
end

class BeerContraption < ActiveRecord::Base
  include StateContraption

  STATES = ['wistful_notion', 'ordered', 'served', 'drinking', 'empty']
  state_group :just_served, ['served']
  state_group :served, ['served', 'drinking', 'empty']
  state_group :drinkable, ['served', 'drinking']
  state_group :empty, ['empty']

  # You probably always want this line, but I leave it up to the individual class to decide; I hate validations in gems
  validates :state, presence: true, inclusion: { in: STATES }

  validate_in_states DRINKABLE_STATES do |s|
    s.validates :beer_level, numericality: { greater_than: 0 }
  end

  validate_in_states JUST_SERVED_STATES do |s|
    s.validate :beer_is_full
  end

  validate_in_states NOT_SERVED_STATES do |s|
    s.validates :paid_for, inclusion: {in: [false]}
  end

  def sip
    if drinkable?
      self.beer_level -= 1.sip
      if beer_level <= 0
        self.beer_level = 0
        self.state = 'empty'
      else
        self.state = 'drinking'
      end
    else
      raise "Not drinkable"
    end
  end

  private
  def beer_is_full
    unless beer_level == capacity
      errors.add(:beer_level, 'is not full')
    end
  end
end

describe BeerContraption do
  context "that exists only in my mind" do
    subject { BeerContraption.new(state: 'wistful_notion') }

    it "should not be drinkable" do
      subject.should_not be_drinkable
      expect { subject.sip }.to raise_error
    end
  end

  context "that is just served" do
    subject { BeerContraption.new(state: 'served', beer_level: 1.pint) }
    it { should be_valid }

    context "but the bartender stole a sip" do
      before { subject.beer_level -= 1.sip }
      it { should_not be_valid }
    end
  end

  context "with barely a sip left" do
    subject { BeerContraption.new(state: 'drinking', beer_level: 0.8.sips) }
    it { should be_valid }

    it "should be empty after I sip it" do
      subject.sip
      subject.should be_valid
      subject.should be_empty
      subject.should_not be_drinkable
    end
  end

  context "still drinking an empty beer" do
    subject { BeerContraption.new(state: 'drinking', beer_level: 0) }
    it { should_not be_valid }
  end

  context "paid for before it arrives" do
    subject { BeerContraption.new(state: 'ordered', paid_for: true) }
    it { should_not be_valid }

    context "but then it gets there" do
      before { subject.update_attributes(state: 'served', beer_level: subject.capacity) }
      it { should be_valid }
    end
  end

  context "with a bunch on the bar" do
    before do
      @beer1 = BeerContraption.create!(state: 'served', beer_level: 1.pint)
      @beer2 = BeerContraption.create!(state: 'drinking', beer_level: 0.5.pints)
      @beer3 = BeerContraption.create!(state: 'empty', beer_level: 0)
    end

    it "should be able to find beers I can and can't drink from" do
      BeerContraption.drinkable.all.should =~ [@beer1, @beer2]
      BeerContraption.not_drinkable.all.should =~ [@beer3]
    end
  end
end
