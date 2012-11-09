# StateContraption

State Contraption supports a particular pattern for lightweight ActiveRecord state machines.

Rather then prescribing everything about how your machine is going to work, State Contraption just provides a couple helper methods to make AR objects with states easier to manage. In particular, no attempt is made to govern how state changes happen or what they might trigger; so you don't have to fight any defaults about that.

## Assumptions

State Contraption assumes that the object's state will be a string stored in a 'state' attribute, and that a STATES constant will be defined with an array of all possible states. A typical setup might look like:

    class BeerContraption < ActiveRecord::Base
      include StateContraption

      STATES = ['wistful_notion', 'ordered', 'served', 'drinking', 'empty']

      # You probably always want this line, but I leave it up to the individual class to decide; I hate validations in gems
      validates :state, presence: true, inclusion: { in: STATES }

    ...

## Usage

State Contraption provides two methods:

### state_group

The state_group method allows you to define a group of states, for instance:

    class BeerContraption < ActiveRecord::Base
      ...
      state_group :drinkable, ['served', 'drinking']

The idea is that code that uses the contraption should not query the state attribute directly, but rather ask questions about it that are answered by state groups. What I get when I set up a state group is:

    # Instance boolean method
    beer.drinkable?

    # Class AREL scopes
    BeerContraption.drinkable
    BeerContraption.not_drinkable

    # Class state-group array constants; these should generally only be used within the class, for validations; see below
    BeerContraption::DRINKABLE_STATES
    BeerContraption::NOT_DRINKABLE_STATES

### validate_in_states

Frequently you only want validations to apply to an object in certain states. State Contraption takes care of this for you in a nice readable way:

    class BeerContraption < ActiveRecord::Base
      ...
      validate_in_states DRINKABLE_STATES do |s|
        s.validates           :beer_level,  numericality: { greater_than: 0 }
        s.validates_datetime  :served_at,   after: "5 pm"
        s.validate            :beer_is_what_i_ordered
      end

This method works with anything that looks and quacks like a validation method in the sense that it begins with 'validate' and supports an :if lambda option.

## Examples

For a more complete example, check out the spec. Or go read the implementation, which is shorter than this readme.

