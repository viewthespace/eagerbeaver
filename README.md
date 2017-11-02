# EagerBeaver

Rails `eager_load`, `includes`, `preload` can break when changing table or association names. These breaking changes are often discovered in production due to the tricky nature of testing the existence of all the associations listed in the `includes`. Proper testing is error prone because it requires that all of the listed associations are built during the tests. This gem makes it trivial to test that the associations exist so that you can quickly find the `includes` to fix when refactoring data models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eagerbeaver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eagerbeaver

## Usage

The constructor takes the model as the first parameter and the `includes` array as the second parameter:
`EagerBeaver.new(MyModel, [:association1, :association2, assoc3: { foo: :bar }])`

The instance has one public method, `.errors`, which returns an array of error messages describing unknown associations.

Imagine we have the following class:
```ruby
class Lease < ActiveRecord::Base
  has_many :lease_terms
  has_many :spaces, through: :lease_terms
  belongs_to :tenant
end
```

with the corresponding controller:
```ruby
class LeasesController < ApplicationController
  def index
    leases = Lease.all.includes(self.class.lease_includes)
    # do some stuff
  end

  def self.lease_includes
    [
      :lease_terms,
      :spaces,
      :tenant,
      :foobar
    ]
  end
end
```

We can ensure that our `lease_includes` is valid by testing it:
```ruby
describe LeasesController do
  describe 'includes' do
    it 'is valid' do
      expect(EagerBeaver.new(Lease, LeasesController.lease_includes).errors).to be_empty
    end
  end
end
```

This expectation would fail, because `.errors` will return `['foobar is not an association of Lease']`.

### Nested Associations

EagerBeaver works with nested associations that are aliased with `source` and `class_name` as well.

```ruby
class Lease < ActiveRecord::Base
  has_many :targets, class_name: 'right'

  has_one :primary_account, through: :targets, source: :account
end

class Right < ActiveRecord::Base
  belongs_to :account
  belongs_to :lease
  belongs_to :space
  belongs_to :floor

  has_many :lease_terms
end

class Account < ActiveRecord::Base
  has_many :properties
end

describe Lease do
  describe 'includes' do
    let!(:includes) do
      [
        { targets: [:space, :floor] },
        { primary_account: :properties }
      ]
    end

    it 'is valid' do
      expect(EagerBeaver.new(Lease, includes).errors).to be_empty # success!
    end
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
