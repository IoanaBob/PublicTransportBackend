RSpec.describe Location, type: :request do
  subject { response.body.blank? ? nil : JSON.parse(response.body) }

  describe 'get list of locations' do
    before { Location.delete_all }
    let(:request) { get '/locations' }

    context 'when empty' do
      before { request }
      it { is_expected.to be_empty }
    end

    context 'when not empty' do
      let!(:location) { FactoryBot.create :location }
      before { request }
      it { is_expected.to include(JSON.parse(location.to_json))}
    end
  end

  describe 'get location by id' do
    let!(:location) { FactoryBot.create :location }
    let(:request) { get "/location/#{id}"}

    context "when the id does not exist" do
      let(:id) { "9999" }
      it { expect { request }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context "when the id exists" do
      let(:id) { location.id }
      before { request }
      it { is_expected.to eq(JSON.parse(location.to_json)) }
    end
  end

  describe 'post location' do
    before(:each) do
      httpok = instance_double("Net::HTTPOK", :body => { "departures" => { "all" => [] } }.to_json)
      allow(Net::HTTP).to receive(:start).and_return(httpok)
    end
    
    let(:request) { post "/location/#{id}", params: {location: location.attributes} }
    let!(:bus_stop) { FactoryBot.create :bus_stop }
    let(:location) { FactoryBot.build :location }

    context "when the bus stop does not exist" do
      before { request }
      let(:id) { "100" }
      it { expect(response).to have_http_status(:not_found) }
    end

    context "when the bus stop exists" do
      let(:id) { bus_stop.id }

      it 'should return status :ok' do
        request
        expect(response).to have_http_status(:ok)
      end

      it { expect { request }.to change { Location.count }.by(1) }
    end
  end
end
