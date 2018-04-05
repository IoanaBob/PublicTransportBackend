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

      context "when schedule empty" do
        it { stub_http; is_expected.to be_nil}
      end

      context  "when schedule has one element" do
        let(:body) { {"departures" => { "all" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:54", "line_name" => "9" }] } }.to_json }
        it { stub_http; is_expected.to eq({delay: -4, bus_line: "9", aimed_departure_time: "2018-02-27 14:54"})}
      end

      context  "when closest departure is before" do
        let(:body) { {"departures" => { "all" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:40", "line_name" => "8" }, {"date" => "2018-02-27", "aimed_departure_time" => "14:54", "line_name" => "9" }] } }.to_json }
        it { stub_http; is_expected.to eq({delay: -4, bus_line: "9", aimed_departure_time: "2018-02-27 14:54"})}
      end

      context  "when closest departure is after" do
        let(:body) { {"departures" => { "all" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:48", "line_name" => "8" }, {"date" => "2018-02-27", "aimed_departure_time" => "14:54", "line_name" => "9" }] } }.to_json }
        it { stub_http; is_expected.to eq({delay: 2, bus_line: "8", aimed_departure_time: "2018-02-27 14:48"})}
      end
    end

    describe "find_delay_for_departure" do
      subject { timetable.find_delay_for_departure({"date" => "2018-02-27", "aimed_departure_time" => time, "line_name" => "9" }) }

      context "when there's no relevant location information" do
        let(:time) { "14:30" }
        it {is_expected.to be_nil }
      end

      context "when there is a location aimed to leave at the same time" do
        before { FactoryBot.create :location }
        let(:time) { "14:30" }
        it { is_expected.to eq(5) }
      end

      context "when there is a location aimed to leave within +- 1 hour" do
        before { FactoryBot.create :location }
        let(:time) { "14:48" }
        it { is_expected.to eq(5) }
      end

      context "when there is a location aimed to leave within +- 1 hour" do
        before { FactoryBot.create :location }
        let(:time) { "14:48" }
        it { is_expected.to eq(5) }
      end
    end

    describe "add_delays_to_schedule" do
      before { FactoryBot.create :location }
      subject { timetable.add_delays_to_schedule }

      context "when nothing in schedule" do
        it { is_expected.to be_blank }
      end

      context "when delay not found" do
        let(:body) { { "departures" => { "all" => [{"mode" => "bus", "line" => "i'm fake", "line_name" => "FAKE", "direction" => "who cares", "operator" => "O1", "operator_name" => nil, "date" => "2018-02-27", "aimed_departure_time" => "14:25", "expected_departure_date" => nil, "expected_departure_time" => nil, "dir" => "outbound" }] } }.to_json }
        it { is_expected.to include a_hash_including("expected_departure_time"=>"unknown", "expected_departure_date"=>"unknown") }
      end

      context "when one item in schedule" do
        let(:body) { { "departures" => { "all" => [{"mode" => "bus", "line" => "9--6", "line_name" => "9", "direction" => "who cares", "operator" => "O1", "operator_name" => nil, "date" => "2018-02-27", "aimed_departure_time" => "14:25", "expected_departure_date" => nil, "expected_departure_time" => nil, "dir" => "outbound" }] } }.to_json }
        it { is_expected.to include a_hash_including("expected_departure_time"=>"14:30", "expected_departure_date"=>"2018-02-27") }
      end

      context "when multiple in schedule" do
        let(:body) { { "departures" => { "all" => [{"mode" => "bus","line" => "9--6","line_name" => "9","direction" => "who cares","operator" => "O1","operator_name" => nil,"date" => "2018-02-27","aimed_departure_time" => "14:25","expected_departure_date" => nil,"expected_departure_time" => nil,"dir" => "outbound"}, {"mode" => "bus","line" => "9--6","line_name" => "9","direction" => "who cares","operator" => "O1","operator_name" => nil,"date" => "2018-02-27","aimed_departure_time" => "14:40","expected_departure_date" => nil,"expected_departure_time" => nil,"dir" => "outbound"}] } }.to_json }
        it { is_expected.to include a_hash_including("expected_departure_time" => "14:30", "expected_departure_date" => "2018-02-27") }
      end
    end
  end
end