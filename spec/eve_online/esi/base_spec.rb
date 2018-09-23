# frozen_string_literal: true

require 'spec_helper'

describe EveOnline::ESI::Base do
  specify { expect(described_class).to be_a(Memoist) }

  describe '#initialize' do
    context 'with options' do
      let(:parser) { double }

      let(:options) do
        {
          token: 'token123',
          parser: parser,
          read_timeout: 30,
          open_timeout: 45,
          etag: '6f2d3caa79a79bc9e61aa058e18905faac5e293fa1729637648ce9a1',
          datasource: 'singularity'
        }
      end

      subject { described_class.new(options) }

      its(:token) { should eq('token123') }

      its(:parser) { should eq(parser) }

      its(:_read_timeout) { should eq(30) }

      its(:_open_timeout) { should eq(45) }

      its(:etag) { should eq('6f2d3caa79a79bc9e61aa058e18905faac5e293fa1729637648ce9a1') }

      its(:datasource) { should eq('singularity') }
    end

    context 'without options' do
      its(:token) { should eq(nil) }

      its(:parser) { should eq(JSON) }

      its(:_read_timeout) { should eq(60) }

      its(:_open_timeout) { should eq(60) }

      its(:etag) { should eq(nil) }

      its(:datasource) { should eq('tranquility') }
    end
  end

  describe '#url' do
    specify { expect { subject.url }.to raise_error(NotImplementedError) }
  end

  describe '#scope' do
    specify { expect { subject.scope }.to raise_error(NotImplementedError) }
  end

  describe '#user_agent' do
    specify { expect(subject.user_agent).to eq("EveOnline API (https://github.com/biow0lf/eve_online) v#{ EveOnline::VERSION }") }
  end

  describe '#http_method' do
    specify { expect(subject.http_method).to eq('Get') }
  end

  describe '#read_timeout' do
    before do
      #
      # subject.client.read_timeout
      #
      expect(subject).to receive(:client) do
        double.tap do |a|
          expect(a).to receive(:read_timeout)
        end
      end
    end

    specify { expect { subject.read_timeout }.not_to raise_error }
  end

  describe '#read_timeout=' do
    let(:value) { double }

    before do
      #
      # subject.client.read_timeout = value
      #
      expect(subject).to receive(:client) do
        double.tap do |a|
          expect(a).to receive(:read_timeout=).with(value)
        end
      end
    end

    specify { expect { subject.send(:read_timeout=, value) }.not_to raise_error }
  end

  describe '#open_timeout' do
    before do
      #
      # subject.client.open_timeout
      #
      expect(subject).to receive(:client) do
        double.tap do |a|
          expect(a).to receive(:open_timeout)
        end
      end
    end

    specify { expect { subject.open_timeout }.not_to raise_error }
  end

  describe '#open_timeout=' do
    let(:value) { double }

    before do
      #
      # subject.client.open_timeout = value
      #
      expect(subject).to receive(:client) do
        double.tap do |a|
          expect(a).to receive(:open_timeout=).with(value)
        end
      end
    end

    specify { expect { subject.send(:open_timeout=, value) }.not_to raise_error }
  end

  describe '#current_etag' do
    let(:resource) { double }

    let(:header) { double }

    let(:etag) { double }

    before { expect(subject).to receive(:resource).and_return(resource) }

    before { expect(resource).to receive(:header).and_return(header) }

    before { expect(header).to receive(:[]).with('Etag').and_return(etag) }

    before { expect(etag).to receive(:gsub).with('"', '') }

    specify { expect { subject.current_etag }.not_to raise_error }
  end

  describe '#page' do
    specify { expect(subject.page).to eq(nil) }
  end

  describe '#total_pages' do
    let(:resource) { double }

    let(:header) { double }

    let(:pages) { double }

    before { expect(subject).to receive(:resource).and_return(resource) }

    before { expect(resource).to receive(:header).and_return(header) }

    before { expect(header).to receive(:[]).with('X-Pages').and_return(pages) }

    before { expect(pages).to receive(:to_i) }

    specify { expect { subject.total_pages }.not_to raise_error }
  end

  describe '#client' do
    context 'when @client set' do
      let(:client) { double }

      before { subject.instance_variable_set(:@client, client) }

      specify { expect(subject.client).to eq(client) }
    end

    # context 'when @client not set' do
    #   let(:client) { double }
    #
    #   before { expect(Faraday).to receive(:new).and_return(client) }
    #
    #   let(:user_agent) { double }
    #
    #   before { expect(subject).to receive(:user_agent).and_return(user_agent) }
    #
    #   before do
    #     #
    #     # faraday.headers[:user_agent] = user_agent
    #     #
    #     expect(client).to receive(:headers) do
    #       double.tap do |a|
    #         expect(a).to receive(:[]=).with(:user_agent, user_agent)
    #       end
    #     end
    #   end
    #
    #   let(:_read_timeout) { double }
    #
    #   before { expect(subject).to receive(:_read_timeout).and_return(_read_timeout) }
    #
    #   before do
    #     expect(client).to receive(:options) do
    #       double.tap do |a|
    #         expect(a).to receive(:timeout=).with(_read_timeout)
    #       end
    #     end
    #   end
    #
    #   let(:_open_timeout) { double }
    #
    #   before { expect(subject).to receive(:_open_timeout).and_return(_open_timeout) }
    #
    #   before do
    #     expect(client).to receive(:options) do
    #       double.tap do |a|
    #         expect(a).to receive(:open_timeout=).with(_open_timeout)
    #       end
    #     end
    #   end
    #
    #   context 'when token not present' do
    #     before { expect(client).not_to receive(:authorization) }
    #
    #     specify { expect(subject.client).to eq(client) }
    #
    #     specify { expect { subject.client }.to change { subject.instance_variable_get(:@client) }.from(nil).to(client) }
    #   end
    #
    #   context 'when token is present' do
    #     let(:options) { { token: 'token123' } }
    #
    #     subject { described_class.new(options) }
    #
    #     before { expect(client).to receive(:authorization).with(:Bearer, 'token123') }
    #
    #     specify { expect(subject.client).to eq(client) }
    #
    #     specify { expect { subject.client }.to change { subject.instance_variable_get(:@client) }.from(nil).to(client) }
    #   end
    # end
  end

  describe '#request' do
    context 'when @request set' do
      let(:request) { double }

      before { subject.instance_variable_set(:@request, request) }

      specify { expect(subject.request).to eq(request) }
    end
  end

  describe '#uri' do
    context 'when @uri set' do
      let(:uri) { double }

      before { subject.instance_variable_set(:@uri, uri) }

      specify { expect(subject.uri).to eq(uri) }
    end

    context 'when @uri not set' do
      let(:url) { double }

      let(:uri) { double }

      before { expect(subject).to receive(:url).and_return(url) }

      before { expect(URI).to receive(:parse).with(url).and_return(uri) }

      specify { expect { subject.uri }.not_to raise_error }

      specify { expect { subject.uri }.to change { subject.instance_variable_get(:@uri) }.from(nil).to(uri) }
    end
  end

  describe '#resource' do
    context 'when @resource set' do
      let(:resource) { double }

      before { subject.instance_variable_set(:@resource, resource) }

      specify { expect(subject.resource).to eq(resource) }
    end

    context 'when @resource not set' do
      let(:resource) { double }

      let(:client) { double }

      let(:request) { double }

      before { expect(subject).to receive(:request).and_return(request) }

      before { expect(subject).to receive(:client).and_return(client) }

      before { expect(client).to receive(:request).with(request).and_return(resource) }

      specify { expect { subject.resource }.not_to raise_error }

      specify { expect { subject.resource }.to change { subject.instance_variable_get(:@resource) }.from(nil).to(resource) }
    end
  end

  describe '#no_content?' do
    let(:resource) { double }

    before { expect(subject).to receive(:resource).and_return(resource) }

    before { expect(resource).to receive(:is_a?).with(Net::HTTPNotModified) }

    specify { expect { subject.no_content? }.not_to raise_error }
  end

  describe '#content' do
    # context 'when status 200' do
    #   let(:resource) { double }
    #
    #   let(:body) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource).twice }
    #
    #   before { expect(resource).to receive(:status).and_return(200) }
    #
    #   before { expect(resource).to receive(:body).and_return(body) }
    #
    #   specify { expect(subject.content).to eq(body) }
    #
    #   specify { expect { subject.content }.not_to raise_error }
    #
    #   specify { expect { subject.content }.to change { subject.instance_variable_defined?(:@_memoized_content) }.from(false).to(true) }
    # end

    # context 'when status 201' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(201) }
    #
    #   specify { expect { subject.content }.to raise_error(NotImplementedError) }
    # end

    # context 'when status 204' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(204) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::NoContent) }
    # end

    # context 'when status 304' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(304) }
    #
    #   specify { expect { subject.content }.to raise_error(NotImplementedError) }
    # end

    # context 'when status 400' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(400) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::BadRequest) }
    # end

    # context 'when status 401' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(401) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::Unauthorized) }
    # end

    # context 'when status 403' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(403) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::Forbidden) }
    # end

    # context 'when status 404' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(404) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::ResourceNotFound) }
    # end

    # context 'when status 500' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(500) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::InternalServerError) }
    # end

    # context 'when status 502' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(502) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::BadGateway) }
    # end

    # context 'when status 503' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(503) }
    #
    #   specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::ServiceUnavailable) }
    # end

    # context 'when status not supported' do
    #   let(:resource) { double }
    #
    #   before { expect(subject).to receive(:resource).and_return(resource) }
    #
    #   before { expect(resource).to receive(:status).and_return(1000) }
    #
    #   specify { expect { subject.content }.to raise_error(NotImplementedError) }
    # end

    context 'when Net::HTTP throw Net::OpenTimeout' do
      before { expect(subject).to receive(:resource).and_raise(Net::OpenTimeout) }

      specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::Timeout) }
    end

    context 'when Net::HTTP throw Faraday::TimeoutError' do
      before { expect(subject).to receive(:resource).and_raise(Net::ReadTimeout) }

      specify { expect { subject.content }.to raise_error(EveOnline::Exceptions::Timeout) }
    end
  end

  describe '#response' do
    let(:parser) { double }

    let(:content) { 'some content to parse' }

    before { expect(subject).to receive(:content).and_return(content) }

    before { expect(subject).to receive(:parser).and_return(parser) }

    before { expect(parser).to receive(:parse).with(content) }

    specify { expect { subject.response }.not_to raise_error }

    specify { expect { subject.response }.to change { subject.instance_variable_defined?(:@_memoized_response) }.from(false).to(true) }
  end

  # private methods

  describe '#parse_datetime_with_timezone' do
    let(:value) { double }

    before do
      #
      # ActiveSupport::TimeZone['UTC'].parse(value)
      #
      expect(ActiveSupport::TimeZone).to receive(:[]).with('UTC') do
        double.tap do |a|
          expect(a).to receive(:parse).with(value)
        end
      end
    end

    specify { expect { subject.send(:parse_datetime_with_timezone, value) }.not_to raise_error }
  end
end
