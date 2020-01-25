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
        let(:o) { double('o') }
        let(:s) { double('s') }
        let(:t) { double('t') }

        it 'sets up "o", "s", and "t" according to the plan' do
          expect(SmarterCSV).to receive(:process).with('output-cc-file.csv').ordered.and_return(o)
          expect(SmarterCSV).to receive(:process).with('orig-cc-file.csv').ordered.and_return(s)
          expect(EmpfinRequestForm::RowReader).to receive(:filter_orig_by_output).with(orig: s, output: o).and_return(t)

          subject.send(:setup_csv_context)
          r = {o: subject.send(:o), s: subject.send(:s), t: subject.send(:t)}
          expect(r).to eq({o: o, s: s, t: t})
        end
      end

      describe "#main_loop" do
        it 'pending' do
          subject.send(:main_loop)
        end
      end
    end
  end
end
