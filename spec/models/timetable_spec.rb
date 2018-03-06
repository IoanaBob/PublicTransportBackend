require 'rails_helper'

RSpec.describe Timetable do
  let(:body) { {"departures" => { "all" => [] } }.to_json }
  let(:httpok) { instance_double("Net::HTTPOK", :body => body) }
  let(:stub_http) { allow(Net::HTTP).to receive(:start).and_return(httpok) }

  let(:timetable) { Timetable.new(atcocode: "5710AWA10617", datetime: "2018-02-27 14:50:17") }

  describe "class function" do
    before { stub_http }

    describe "refresh_schedule" do
      subject { timetable.refresh_schedule }

      context "when correct atcocode and time" do
        it { is_expected.to eq(JSON.parse([].to_json))}
      end
    end

    describe "get_delay_for_bus" do
      subject { timetable.get_delay_for_bus }

      describe "when schedule empty" do
        it { stub_http; is_expected.to be(:none)}
      end

      describe  "when schedule has one element" do
        let(:body) { {"departures" => { "all" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:54", "line_name" => "9" }] } }.to_json }
        it { stub_http; is_expected.to eq({delay: 4, bus_line: "9"})}
      end

      describe  "when closest departure is before" do
        let(:body) { {"departures" => { "all" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:40", "line_name" => "8" }, {"date" => "2018-02-27", "aimed_departure_time" => "14:54", "line_name" => "9" }] } }.to_json }
        it { stub_http; is_expected.to eq({delay: 4, bus_line: "9"})}
      end

      describe  "when closest departure is after" do
        let(:body) { {"departures" => { "all" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:48", "line_name" => "8" }, {"date" => "2018-02-27", "aimed_departure_time" => "14:54", "line_name" => "9" }] } }.to_json }
        it { stub_http; is_expected.to eq({delay: -2, bus_line: "8"})}
      end
    end
  end

end