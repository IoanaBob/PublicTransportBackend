require 'rails_helper'

RSpec.describe BusStop, type: :model do
  describe "Validations" do
    context "when valid" do
      subject { FactoryBot.create :bus_stop }
      it { expect { subject }.to change { BusStop.count }.by(1) }
    end

    context "when invalid" do
      subject { FactoryBot.create :bus_stop, mode: "train" }
      
      it do
        expect { subject }
          .to raise_error(ActiveRecord::RecordInvalid)
          .and change { BusStop.count }.by(0)
      end
    end

    describe "#atcocode" do
      subject { FactoryBot.build :bus_stop, atcocode: atcocode }

      context "when not present" do
        let(:atcocode) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when duplicate" do
        let(:atcocode) { "5710AWA10617" }
        it { FactoryBot.create :bus_stop; is_expected.not_to be_valid }
      end
    end

    describe "#mode" do
      subject { FactoryBot.build :bus_stop, mode: mode }

      context "when not == bus" do
        let(:mode) { "train" }
        it { is_expected.not_to be_valid }
      end

      context "when == bus" do
        let(:mode) { "bus" }
        it { is_expected.to be_valid }
      end
    end

    describe "#name" do
      subject { FactoryBot.build :bus_stop, name: name }

      context "when not present" do
        let(:name) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when less than 3 characters" do
        let(:name) { "fa" }
        it { is_expected.not_to be_valid }
      end
    end

    describe "#stop_name" do
      subject { FactoryBot.build :bus_stop, stop_name: stop_name }

      context "when not present" do
        let(:stop_name) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when less than 3 characters" do
        let(:stop_name) { "fa" }
        it { is_expected.not_to be_valid }
      end
    end

    describe "#bearing" do
      subject { FactoryBot.build :bus_stop, bearing: bearing }

      context "when > 2 characters" do
        let(:bearing) { "SWS" }
        it { is_expected.not_to be_valid }
      end

      context "when length == 1" do
        let(:bearing) { "S" }
        it { is_expected.to be_valid }      
      end

      (["A".."Z"] - ["S", "N", "W", "E"]).each do |invalid_char|
        context "when includes character #{invalid_char}" do
          let(:bearing) { "#{invalid_char}" }
          it { is_expected.not_to be_valid }
        end
      end

      context "when not capitalised" do
        subject { FactoryBot.create :bus_stop, bearing: "sw" }
        it { expect(subject.bearing).to eq("SW") }
      end
    end

    describe "#longitude" do
      subject { FactoryBot.build :bus_stop, longitude: longitude }

      context "when not present" do
        let(:longitude) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when not float" do
        let(:longitude) { "hi" }
        it { is_expected.not_to be_valid }
      end
    end

    describe "#latitude" do
      subject { FactoryBot.build :bus_stop, latitude: latitude }

      context "when not present" do
        let(:latitude) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when not float" do
        let(:latitude) { "hi" }
        it { is_expected.not_to be_valid }
      end
    end

    describe "#distance" do
      subject { FactoryBot.build :bus_stop, distance: distance }

      context "when not present" do
        let(:distance) { nil }
        it { is_expected.not_to be_valid }
      end

      context "when not integer" do
        let(:distance) { "hi" }
        it { is_expected.not_to be_valid }
      end
    end
  end
end
