require 'spec_helper'

RSpec.describe 'Task' do
  context 'some methods' do
    context '.do_work(value)' do
      context '  does work   ' do
        it ' \t \t \t  for some values           ' do
          expect(1).to eq(1)
        end
      end
    end
  end
end
