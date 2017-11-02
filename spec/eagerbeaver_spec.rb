require "spec_helper"

RSpec.describe EagerBeaver do
  describe 'lease' do
    let!(:model) { Lease }

    context 'when all associations exist' do
      let!(:includes) do
        [
          :lease_terms,
          { spaces: :floor },
          { spaces: { floor: [:property, :right_targets] } },
          { spaces: { floor: :property } },
          :tenant,
          { spaces: { targeted_by: { lease_terms: :space_lease_terms } } },
          { spaces: { prop: :floors } },
          { spaces: { acc: :properties } }
        ]
      end

      subject { described_class.new(model, includes) }

      it 'returns an empty array' do
        expect(subject.errors).to be_empty
      end
    end

    context 'when associations do not exist' do
      let!(:includes) do
        [
          :lease_term,
          :floor,
          { spaces: :floor },
          { space: :floor },
          { spaces: :floors },
          { space: { prop: { floors: :foobars } } }
        ]
      end
      let!(:expected_errors) do
        [
          'lease_term is not an association of Lease',
          'floor is not an association of Lease',
          'space is not an association of Lease',
          'floors is not an association of Space',
          'foobars is not an association of Floor',
          'space is not an association of Lease',
        ]
      end

      subject { described_class.new(model, includes) }

      it 'returns the expected missing associations' do
        expect(subject.errors).to match_array(expected_errors)
      end
    end
  end
end
