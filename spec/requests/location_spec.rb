RSpec.describe Location, type: :request do
  subject { response.body.blank? ? nil : JSON.parse(body) }

  describe 'get list of locations' do
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
    let(:request) { post "/location/#{atcocode}", params: {location: location.attributes} }
    let!(:bus_stop) { FactoryBot.create :bus_stop }
    let(:location) { FactoryBot.build :location }

    context "when the atcocode does not exist" do
      before { request }
      let(:atcocode) { "AWD32412AD" }
      it { expect(response).to have_http_status(:not_found) }
    end

    context "when the atcocode exists" do
      let(:atcocode) { bus_stop.atcocode }

      it 'should return status :ok' do
        request
        expect(response).to have_http_status(:ok)
      end

      it { expect { request }.to change { Location.count }.by(1) }
    end
  end
end
