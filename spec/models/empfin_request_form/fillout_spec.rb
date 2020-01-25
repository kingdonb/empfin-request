require 'rails_helper'

RSpec.describe EmpfinRequestForm::Fillout do
  xcontext "fill out the form, heavy lifting" do
    describe 'fill out part one' do
      it 'pending' do
        subject.fill_out_1
      end
    end
    describe 'fill out part two' do
      it 'pending' do
        subject.fill_out_2
      end
    end
    describe 'submit part one' do
      it 'pending' do
        subject.submit_1
      end
    end
    describe 'submit part two' do
      it 'pending' do
        subject.submit_2
      end
    end
  end
  xcontext "other utility methods" do
    it '#follow_req_link' do
      subject.follow_req_link
    end
    it '#find_ritm_number' do
      subject.find_ritm_number
    end
    it '#find_task_number' do
      subject.find_task_number
    end
    it '#describe_what_work' do
      subject.describe_what_work
    end
    it '#group_entry' do
      subject.group_entry
    end
    it '#assign_user' do
      subject.assign_user
    end
    it '#yes_on_behalf_of' do
      subject.yes_on_behalf_of
    end
  end
end
