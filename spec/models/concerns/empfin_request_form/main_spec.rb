require 'rails_helper'

RSpec.describe EmpfinRequestForm::Main do
  context "holds a context from ApplicationSystemTestCase" do
    describe "#run" do
      it 'organizer interactor' do
        expect(subject).to receive(:do_login)
        expect(subject).to receive(:validate_login_destination)
        expect(subject).to receive(:setup_csv_context)
        expect(subject).to receive(:main_loop)

        subject.run
      end
    end

    describe "#do_login" do
      it 'pending'
    end

    describe "#validate_login_destination" do
      it 'pending'
    end

    describe "#setup_csv_context" do
      it 'pending'
    end

    describe "#main_loop" do
      it 'pending'
    end

  end
end
