# frozen_string_literal: true

require 'spec_helper'

describe EveOnline::ESI::CharacterWallet do
  let(:options) { { token: 'token123', character_id: 12_345_678 } }

  subject { described_class.new(options) }

  specify { expect(subject).to be_a(EveOnline::ESI::Base) }

  specify { expect(described_class::API_PATH).to eq('/v1/characters/%<character_id>s/wallet/?datasource=%<datasource>s') }

  describe '#initialize' do
    its(:token) { should eq('token123') }

    its(:parser) { should eq(JSON) }

    its(:_read_timeout) { should eq(60) }

    its(:_open_timeout) { should eq(60) }

    its(:datasource) { should eq('tranquility') }

    its(:character_id) { should eq(12_345_678) }
  end

  describe '#as_json' do
    let(:character_wallet) { described_class.new(options) }

    before { expect(character_wallet).to receive(:wallet).and_return(409_488_252.49) }

    subject { character_wallet.as_json }

    its([:wallet]) { should eq(409_488_252.49) }
  end

  describe '#wallet' do
    let(:response) { double }

    before { expect(subject).to receive(:response).and_return(response) }

    specify { expect(subject.wallet).to eq(response) }
  end

  describe '#scope' do
    specify { expect(subject.scope).to eq('esi-wallet.read_character_wallet.v1') }
  end

  describe '#url' do
    specify do
      expect(subject.url).to eq('https://esi.evetech.net/v1/characters/12345678/wallet/?datasource=tranquility')
    end
  end
end
