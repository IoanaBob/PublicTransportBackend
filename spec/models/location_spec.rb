require 'rails_helper'

RSpec.describe Location, type: :model do
  describe "Validations" do
    context "when valid" do
      subject { FactoryBot.create :location }
      it { expect { subject }.to change { Location.count }.by(1) }
    end

    context "when invalid" do
      subject { FactoryBot.create :location, latitude: "not a coordinate" }
      
      it do
        expect { subject }
          .to raise_error(ActiveRecord::RecordInvalid)
          .and change { Location.count }.by(0)
      end
    end

    describe "#latitude" do
      subject { FactoryBot.build :location, latitude: latitude }

      context "when not float" do
        let(:latitude) { "hi" }
        it { is_expected.not_to be_valid }
      end
    end
    
    describe "#longitude" do
      subject { FactoryBot.build :location, longitude: longitude }

      context "when not float" do
        let(:longitude) { "hi" }
        it { is_expected.not_to be_valid }
      end
    end

    describe "#current_speed" do
      subject { FactoryBot.build :location, current_speed: current_speed }

      context "when not float" do
        let(:current_speed) { "hi" }
        it { is_expected.not_to be_valid }
      end
    end

    describe "#time" do
      subject { FactoryBot.build :location, time: time }

      context "when not datetime" do
        let(:time) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when later than current time" do
        let(:time) { "2999-02-27 14:25:17" }
        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "class function" do
    describe "is_weekday" do
      subject { (FactoryBot.build :location, time: time).is_weekday }

      context "when friday" do
        let(:time) { "2018-02-23 14:25:17" }
        it { is_expected.to be true}
      end

      context "when saturday" do
        let(:time) { "2018-02-24 14:25:17" }
        it { is_expected.to be false}
      end
    end

    describe "expected_time" do
      let!(:time) { "2018-02-24 14:25:17" }
      subject { (FactoryBot.build :location, delay: delay, time: time).expected_time }

      context "when delay positive" do
        let(:delay) { 3 }
        it { is_expected.to eq("2018-02-24 14:22:17")}
      end

      context "when delay negative" do
        let(:delay) { -5 }
        it { is_expected.to eq("2018-02-24 14:30:17")}
      end
    end
  end

  describe "scope" do
    describe "where_aimed_time" do
      before { FactoryBot.create :location }
      subject { Location.where_aimed_time(time).first }
      
      context "when time = aimed time" do
        let!(:time) { "14:30" }
        it {is_expected.to have_attributes(Location.first.attributes)}
      end
      context "when time != aimed time" do
        let!(:time) { "14:20" }
        it { is_expected.to be_blank }
      end
    end

    describe "aimed_in_time_range" do
      before { FactoryBot.create :location }
      subject { Location.where_aimed_in_time_range(starting, ending).first }

      context "when location in time range" do
        let(:starting) { "14:00" }
        let(:ending) { "16:00" }
        it {is_expected.to have_attributes(Location.first.attributes)}
      end

      context "when location not in time range" do
        let(:starting) { "12:30" }
        let(:ending) { "13:30" }
        it { is_expected.to be_blank }
      end
    end

    describe "where_weekday" do
      context "when choosing weekdays" do
        before { FactoryBot.create :location, aimed_departure_time: "2018-02-23 14:25:17" }
        subject { Location.where_weekday(valid).first }

        context "when valid = true" do
          let(:valid) { true }
          it {is_expected.to have_attributes(Location.first.attributes)}
        end

        context "when valid = false" do
          let(:valid) { false }
          it { is_expected.to be_blank }
        end
      end

      context "when choosing weekends" do
        let!(:location) { FactoryBot.create :location, aimed_departure_time: "2018-02-24 14:25:17" }
        subject { Location.where_weekday(valid).first }

        context "when valid = true" do
          let(:valid) { true }
          it { is_expected.to be_blank }
        end
        context "when valid = false" do
          let(:valid) { false }
          it {is_expected.to have_attributes(Location.first.attributes)}
        end
      end
    end

    describe "avergae_delay" do
      subject { Location.average_delay }

      context "when empty" do
        it { is_expected.to be_blank }
      end

      context "when two elements" do
        before { FactoryBot.create :location, delay: 2.0; FactoryBot.create :location, delay: 5.0 }
        
        it { is_expected.to eq(3.5) }
      end    
    end
  end
end
