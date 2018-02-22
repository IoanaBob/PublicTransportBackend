require 'rails_helper'

RSpec.describe 'Timetable API', type: :request do
  describe 'GET/ timetable' do
    before { get '/' }

    it 'returns simple request' do
      expect(json).not_to be_empty
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end
end