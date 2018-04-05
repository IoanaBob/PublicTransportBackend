RSpec.describe Timetable, type: :request do
  subject { response.body.blank? ? nil : JSON.parse(response.body) }

  let(:body) { {"departures" => { "all" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:25", "line_name" => "8" }, {"date" => "2018-02-27", "aimed_departure_time" => "14:33", "line_name" => "9" }] } }.to_json }
  let(:httpok) { instance_double("Net::HTTPOK", :body => body) }
  before { allow(Net::HTTP).to receive(:start).and_return(httpok) }

  describe 'get timetable (list of departures)' do
    
    let(:request) { get "/timetable/5710AWA10617/#{date}/#{time}" }
    let(:date) { "2018-02-27" }
    let(:time) { "14:20:17" }

    context 'when nothing in schedule' do
      before { request }
      let(:body) { {"departures" => { "all" => [] } }.to_json }
      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when no bus stop with atcocode' do
      before { request }
      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when no location in the model' do
      before { request }

      let!(:bus_stop) { FactoryBot.create :bus_stop }
      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when date not valid' do
      let(:date) { "blabla" }
      let!(:bus_stop) { FactoryBot.create :bus_stop, atcocode: "5710AWA10617" }

      before { request }

      it { expect(response).to have_http_status(:bad_request) }
    end

    context 'when time not valid' do
      let(:time) { "blabla" }
      let!(:bus_stop) { FactoryBot.create :bus_stop, atcocode: "5710AWA10617" }

      before { request }

      it { expect(response).to have_http_status(:bad_request) }
    end

    context 'when not empty' do
      let!(:location) { FactoryBot.create :location }
      let!(:bus_stop) { FactoryBot.create :bus_stop, atcocode: "5710AWA10617" }

      before { request }

      it { is_expected.to include a_hash_including("delay" => "5.0") }
    end
  end

  describe 'get timetable (list of departures) for a bus line' do
    let(:request) { get "/timetable/5710AWA10617/#{date}/#{time}/8" }
    let(:date) { "2018-02-27" }
    let(:time) { "14:20:17" }

    context 'when nothing in schedule' do
      before { request }
      let(:body) { {"departures" => { "all" => [] } }.to_json }
      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when no bus stop with atcocode' do
      before { request }
      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when no location in the model' do
      before { request }

      let!(:bus_stop) { FactoryBot.create :bus_stop }
      it { expect(response).to have_http_status(:not_found) }
    end

    context 'when date not valid' do
      let!(:bus_stop) { FactoryBot.create :bus_stop, atcocode: "5710AWA10617" }
      let(:date) { "blabla" }

      before { request }
      
      it { expect(response).to have_http_status(:bad_request) }
    end

    context 'when time not valid' do
      let!(:bus_stop) { FactoryBot.create :bus_stop, atcocode: "5710AWA10617" }
      let(:time) { "blabla" }
      
      before { request }

      it { expect(response).to have_http_status(:bad_request) }
    end

    context 'when not empty' do
      let(:body) { {"departures" => { "8" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:25", "line_name" => "8" }], "9" => [{"date" => "2018-02-27", "aimed_departure_time" => "14:33", "line_name" => "9" }] } }.to_json }
      let!(:location) { FactoryBot.create :location, bus_line: "8" }
      let!(:bus_stop) { FactoryBot.create :bus_stop, atcocode: "5710AWA10617" }
      
      before { request }
      it { is_expected.to include a_hash_including("delay" => "5.0") }
    end
  end
end
