require 'rails_helper'

RSpec.describe EmpfinRequestForm::Fillout do
  let(:ctx) { double('ctx') }
  let(:subject) {
    expect(ctx).to receive(:find).with('#item_table').ordered
    expect(ctx).to receive(:find).with('table td.guide_tray', text: 'Customer Care Request').ordered
    described_class.new(
      ctx: ctx, iframe: nil )
  }
  before(:each) do
    expect(described_class).to receive(:new).with(
      ctx: ctx, iframe: nil
    ).and_call_original
    subject
  end

  context "fill out the form, heavy lifting" do
    describe 'fill out part one' do
      it 'calls #fill_out_1 via #fill_out_1_with_row' do
        w = double('work')
        g = double('group')
        u = double('user')
        o = double('on_behalf')
        expect(subject).to receive(:describe_what_work).with w
        expect(subject).to receive(:group_entry).with g
        expect(subject).to receive(:assign_user).with u
        expect(subject).to receive(:yes_on_behalf_of).with o
        subject.fill_out_1_with_row(
          {short_description: w, group: g, assigned_to: u, behalf_of: o}
        )
      end
    end
    describe 'fill out part two' do
      it 'calls #fill_out_2 via #fill_out_2_with_row' do
        task_short_description = double('desc')
        description            = double('long_desc')
        work_notes             = double('work_note')
        business_application   = double('bus_service')
        priority_order         = double('priority')
        state                  = double('state')
        oit_resources_needed   = double('oit_resources')
        effort_hrs             = double('time_estimate')
        what_delivered         = double('deliverables')
        row = { short_description: task_short_description,
                long_description: description,
                work_note: work_notes,
                bus_service: business_application,
                more_info: priority_order,
                state: state,
                oit_resources: oit_resources_needed,
                time_estimate: effort_hrs,
                deliverables: what_delivered }

        expect(subject).to receive(:fill_out_2).with(
          task_short_description: task_short_description,
          description: description, work_notes: work_notes,
          business_service: business_application,
          business_application_impacted: business_application,
          priority_order: priority_order, state: state,
          what_oit_resources_needed: oit_resources_needed,
          what_do_i_estimate_my_effort_hrs: effort_hrs,
          what_do_i_expect_to_be_delivered: what_delivered
        )
        subject.fill_out_2_with_row(row)
      end
    end
    describe 'submit part one' do
      let(:order_now) { double('order_now') }
      let(:request_link) { double('request_link') }
      let(:req_no) { 'REQ00001' }
      it 'submits after fill_out_1' do
        expect(ctx).to receive(:find).with('button#oi_order_now_button').ordered.and_return(order_now)
        expect(order_now).to receive(:click)
        expect(ctx).to receive(:find).with(
          'span', text: 'Thank you, your request has been submitted').ordered.and_return(order_now)

        expect(ctx).to receive(:find).with('a#requesturl').ordered.and_return request_link
        expect(request_link).to receive(:text).and_return req_no
        expect(subject.submit_1).to eq req_no
      end
    end
    describe 'submit part two' do
      let(:submit_buttons) { [double('submit')] }
      it 'pending' do
        expect(ctx).to receive(:all).with('button', text: 'Update').and_return submit_buttons
        expect(submit_buttons.first).to receive(:click)
        subject.submit_2
      end
    end
  end
  context "other utility methods" do
    describe "get a request number and request url" do
      let(:req_no) { 'REQ00001' }
      let(:req_link) { double('request_link') }
      let(:req_url) { double('request_url') }
      it '#follow_req_link' do
        expect(ctx).to receive(:find).with('a#requesturl', text: req_no).ordered.and_return req_link
        expect(req_link).to receive(:[]).with(:href).and_return req_url
        expect(req_link).to receive(:click)
        expect(subject.follow_req_link('REQ00001')).to eq req_url
      end
    end

    describe "get a request item link and request item number" do
      let(:ritm_link) { double('ritm_link') }
      let(:ritm_url) { double('ritm_url') }
      let(:ritm_no) { double('ritm_no') }
      it '#find_ritm_number' do
        expect(ctx).to receive(:find).with('span.tab_caption_text', text: 'Requested Items').ordered
        expect(ctx).to receive(:find).with('a.linked.formlink', text: 'RITM00').ordered.and_return ritm_link
        expect(ritm_link).to receive(:text).and_return ritm_no
        expect(subject.find_ritm_number).to eq [ritm_link, ritm_no]
      end
    end

    describe "get a task link and task number" do
      let(:task_link) { double('task_link') }
      let(:task_url) { double('task_url') }
      let(:task_no) { double('task_no') }
      it '#find_task_number' do
        expect(ctx).to receive(:find).with('span.tab_caption_text', text: 'Catalog Tasks').ordered
        expect(ctx).to receive(:find).with('a.linked.formlink', text: 'TASK00').ordered.and_return task_link
        expect(task_link).to receive(:text).and_return task_no
        expect(subject.find_task_number).to eq [task_link, task_no]
      end
    end

    context "mostly simple fillout methods" do
      let(:field) { double('field') }
      let(:value) { double('value') }
      describe "fill out the Describe What Work field" do
        it '#describe_what_work' do
          expect(ctx).to receive(:find).with(EmpfinRequestForm::Fillout::DESCRIBE_WHAT_WORK).and_return field
          expect(field).to receive(:set).with(value)
          subject.describe_what_work(value)
        end
      end
      context 'select from a list entry' do
        let(:things_to_click) { [double('span')] }
        it '#group_entry' do
          expect(things_to_click.first).to receive(:click)
          expect(ctx).to receive(:find).with(EmpfinRequestForm::Fillout::GROUP_ENTRY).and_return field
          expect(ctx).to receive(:all).and_return(things_to_click)
          expect(field).to receive(:set).with(value)
          expect(ctx).to receive(:find).with('span', text: value).and_return things_to_click.first
          subject.group_entry(value)
        end
        it '#assign_user' do
          expect(things_to_click.first).to receive(:click)
          expect(ctx).to receive(:find).with(EmpfinRequestForm::Fillout::ASSIGN_USER).and_return field
          expect(ctx).to receive(:all).and_return(things_to_click)
          expect(field).to receive(:set).with(value)
          expect(ctx).to receive(:find).with('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)', text: value).and_return things_to_click.first
          subject.assign_user(value)
        end
        it '#yes_on_behalf_of' do
          checkbox = double('is_on_behalf_of')
          expect(things_to_click.first).to receive(:click)
          expect(checkbox).to receive(:select).with('Yes')
          expect(ctx).to receive(:find).with(EmpfinRequestForm::Fillout::IS_ON_BEHALF_OF).ordered.and_return checkbox
          expect(ctx).to receive(:find).with(EmpfinRequestForm::Fillout::ON_BEHALF_OF_WHOM).ordered.and_return field
          expect(ctx).to receive(:all).and_return(things_to_click)
          expect(field).to receive(:set).with(value)
          expect(ctx).to receive(:find).with('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)', text: value).and_return things_to_click.first
          subject.yes_on_behalf_of(value)
        end
      end
    end
  end
end
