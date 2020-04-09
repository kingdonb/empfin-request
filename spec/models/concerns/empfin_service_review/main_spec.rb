require 'rails_helper'

RSpec.describe EmpfinServiceReview::Main do
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
      let(:clear_search) { double(:clear_search) }
      let(:subject) { described_class.new(ctx: ctx) }
      describe "#do_login" do
        let(:login) { double('login') }
        it 'logs you in' do
          expect(EmpfinServiceReview::Login).to receive(:new).and_return login
          subject.send(:do_login)
        end
      end

      describe "#validate_login_destination" do
        it 'looks for an item_table and the text Customer Care Request' do
          expect(ctx).to receive(:find).with('a[aria-label="Remove next condition Keywords = alphasense"]').ordered.and_return(clear_search)
          expect(clear_search).to receive(:click)
          expect(ctx).to receive(:find).with('h2.navbar-title.list_title', text: 'Business Applications').ordered
          expect(ctx).to receive(:find).with('input[placeholder="Search"]').ordered
          subject.send(:validate_login_destination)
        end
      end

      describe "#setup_csv_context" do
        let(:o) { double('o') }
        let(:s) { double('s') }
        let(:t) { double('t') }
        let(:options) { {:col_sep=>",", :row_sep=>"\n"} }

        it 'sets up "o", "s", and "t" according to the plan' do
          expect(SmarterCSV).to receive(:process).with('output-srv-file.csv', options).ordered.and_return(o)
          expect(SmarterCSV).to receive(:process).with('orig-srv-file.csv', options).ordered.and_return(s)
          expect(EmpfinServiceReview::RowReader).to receive(:filter_orig_by_output).with(orig: s, output: o).and_return(t)

          subject.send(:setup_csv_context)
          r = {o: subject.send(:o), s: subject.send(:s), t: subject.send(:t)}
          expect(r).to eq({o: o, s: s, t: t})
        end
      end

      describe "#main_loop" do
        let(:l) { double('login_handle') }
        let(:o) { [{o: double('o'), req_id: 'REQ123'}] }
        let(:t) { [{short_description: 'CC: abc - Priority: ? - #123 xyz'}] }
        let(:ctx) { double('ctx') }
        let(:fillout) { double('fillout') }
        let(:ritm_link) { l = double('link'); allow(l).to receive(:[]).with(:href).and_return 'http://foo'; l }
        let(:task_link) { l = double('link'); allow(l).to receive(:[]).with(:href).and_return 'http://foo'; l }

        it 'main loop hits a bunch of methods' do
          subject.instance_variable_set(:@login_handle, l)
          subject.instance_variable_set(:@o, o)
          subject.instance_variable_set(:@t, t)
          subject.instance_variable_set(:@ctx, ctx)
          expect(subject).to receive(:search_for)
          expect(subject).to receive(:open_record)
          expect(subject).to receive(:arrive_at_business_record)
          # expect(EmpfinServiceReview::Fillout).to receive(:new).with(ctx: ctx, iframe: nil).and_return fillout
          # expect(fillout).to receive(:fill_out_1_with_row)
          # expect(fillout).to receive(:submit_1)
          # expect(fillout).to receive(:follow_req_link)
          # expect(fillout).to receive(:find_ritm_number).and_return([ritm_link, 'RITM1234'])
          # expect(ritm_link).to receive(:click)
          # expect(fillout).to receive(:find_task_number).and_return([task_link, 'TASK1234'])
          # expect(task_link).to receive(:click)
          # expect(fillout).to receive(:fill_out_2_with_row)
          # expect(fillout).to receive(:submit_2)
          # expect(EmpfinServiceReview::CsvWriter).to receive(:to_csv)
          expect(l).to receive(:visit_request_url).with(ctx: ctx)

          subject.send(:main_loop)
        end
      end
    end
  end
end
