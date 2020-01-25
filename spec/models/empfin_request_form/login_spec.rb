require 'rails_helper'

RSpec.describe EmpfinRequestForm::Login do
  describe '#initialize' do
    let(:ctx) { double(:application_system_test_context) }
    let(:username_field) { double('username') }
    let(:password_field) { double('password') }

    it 'takes a ctx and sends some messages to it' do
      expect(ctx).to receive(:visit).with("https://ndtest.service-now.com").ordered
      expect(ctx).to receive(:find).with("#okta-signin-username").ordered.and_return(username_field)
      expect(ctx).to receive(:find).with("#okta-signin-password").ordered.and_return(password_field)
      expect(username_field).to receive(:set)
      expect(password_field).to receive(:set)
      expect(ctx).to receive(:find).with('div.navbar-header', text: "ServiceNow Home Page\nTEST", wait: 30).ordered
      expect(ctx).to receive(:visit).with(EmpfinRequestForm::EMPFIN_REQUEST_URL).ordered

      described_class.new(ctx: ctx)
    end
  end
  context "authentication" do
    describe 'Okta login process' do
      it 'pending'
    end
  end
  context "negotiating the visit" do
    it 'tells the provided context to visit an Employee Finance Request Form URL' do
      pending
    end
  end
end
