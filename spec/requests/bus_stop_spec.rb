require 'rails_helper'

RSpec.describe BusStopController, type: :request do
  subject { response.body.blank? ? nil : JSON.parse(response.body) }

  describe 'get list of bus stops' do
    let(:request) { get '/bus_stops' }

    context 'when empty' do
      before { request }
      it { is_expected.to be_empty }
    end

    context 'when not empty' do
      let!(:bus_stop) { FactoryBot.create :bus_stop }
      before { request }
      it { is_expected.to include(JSON.parse(bus_stop.to_json))}
    end
  end

  describe 'get bus stop by id' do
    let!(:bus_stop) { FactoryBot.create :bus_stop }
    let(:request) { get "/bus_stop/#{id}"}

    context "when the id does not exist" do
      let(:id) { "9999" }
      it { expect { request }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context "when the id exists" do
      let(:id) { bus_stop.id }
      before { request }
      it { is_expected.to eq(JSON.parse(bus_stop.to_json)) }
    end
  end

  describe 'post bus stop' do
    let(:request) { post "/bus_stop", params: {bus_stop: bus_stop_attributes} }
    let(:bus_stop_attributes) { FactoryBot.attributes_for :bus_stop, latitude: latitude }

    context "when doesn't validate" do
      let(:latitude) { "hi" }
      before { request }
      it { expect(response).to have_http_status(:bad_request) }
      #it { expect { request }.to change { BusStop.count }.by(0) }
    end

    context "when validations pass" do
      let(:latitude) { 51.5 }
      it 'should return status :ok' do
        request
        expect(response).to have_http_status(:ok)
      end

      it { expect { request }.to change { BusStop.count }.by(1) }
    end
  end
end
