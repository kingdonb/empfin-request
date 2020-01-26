require 'rails_helper'

RSpec.describe EmpfinRequestForm::Login do
  let(:ctx) { double(:application_system_test_context) }

  describe '#initialize' do
    let(:username_field) { double('username') }
    let(:password_field) { double('password') }

    it 'takes a ctx and sends some messages to it' do
      ## NOTE: the hardcoded string below should not be replaced with SERVICENOW_HOME_PAGE_STRING
      # expect(ctx).to receive(:visit).with("https://ndtest.service-now.com").ordered
      ## NB: I read it, I'm fixing it anyway. *bless*
      # This is meant to guarantee you are not testing in prod. If this test is
      # failing, please check whether it is properly pointed at prod or nonprod
      # environment, before you proceed with testing any changes to the app.
      expect(ctx).to receive(:visit).with("https://sn.nd.edu").ordered
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
      it 'happens opposite the visit to Request Form' do
        allow_any_instance_of(described_class).to receive :visit_request_url
        expect_any_instance_of(described_class).to receive(:okta_heavy_lifting).with(ctx: ctx)
        described_class.new(ctx: ctx)
      end
    end
  end
  context "negotiating the visit" do
    it 'tells the provided context to visit an Employee Finance Request Form URL' do
      expect_any_instance_of(described_class).to receive(:visit_request_url).with(ctx: ctx)
      allow_any_instance_of(described_class).to receive(:okta_heavy_lifting)
      described_class.new(ctx: ctx)
    end
  end
end
