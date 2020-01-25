require 'rails_helper'

RSpec.describe EmpfinRequestForm::Main do
  context "holds a context from ApplicationSystemTestCase" do
    describe "#run" do
      let(:subject) { described_class.
                      new(ctx: double(:application_system_test_context)) }

      it 'organizer interactor' do
        expect(subject).to receive(:do_login)
        expect(subject).to receive(:validate_login_destination)
        expect(subject).to receive(:setup_csv_context)
        expect(subject).to receive(:main_loop)

        subject.run
      end
    end

    context "interactor methods" do
      let(:ctx) { double(:application_system_test_context) }
      let(:subject) { described_class.new(ctx: ctx) }
      describe "#do_login" do
        let(:login) { double('login') }
        it 'logs you in' do
          expect(EmpfinRequestForm::Login).to receive(:new).and_return login
          subject.send(:do_login)
        end
      end

      describe "#validate_login_destination" do
        it 'looks for an item_table and the text Customer Care Request' do
          expect(ctx).to receive(:find).with('#item_table').ordered
          expect(ctx).to receive(:find).with('table td.guide_tray', text: 'Customer Care Request').ordered
          subject.send(:validate_login_destination)
        end
      end

      describe "#setup_csv_context" do
        it 'pending'
      end

      describe "#main_loop" do
        it 'pending'
      end
    end
  end
end
