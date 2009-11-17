require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/rb_support/rb_language'

module Cucumber
    describe 'Pending' do

      before(:each) do
        l = RbSupport::RbLanguage.new(StepMother.new)
        l.begin_rb_scenario(mock('scenario', :null_object => true))
        @world = l.current_world
      end

      it 'should raise a Pending if no block is supplied' do
        lambda {
          @world.pending "TODO"
        }.should raise_error(Pending, /TODO/)
      end

      it 'should raise a Pending if a supplied block fails as expected' do
        lambda {
          @world.pending "TODO" do
            raise "oops"
          end
        }.should raise_error(Pending, /TODO/)
      end

      it 'should raise a Pending if a supplied block fails as expected with a mock' do
        lambda {
          @world.pending "TODO" do
            m = mock('thing')
            m.should_receive(:foo)
            m.rspec_verify
          end
        }.should raise_error(Pending, /TODO/)
      end

      it 'should raise a Pending if a supplied block starts working' do
        lambda {
          @world.pending "TODO" do
            # success!
          end
        }.should raise_error(Pending, /TODO/)
      end

    end
end
