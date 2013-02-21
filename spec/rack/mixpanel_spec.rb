require 'rack/mixpanel'
require 'fakeweb'

describe Rack::Mixpanel do
  let(:distinct_id) { '405e1d32-8e1e-4d04-b1ee-d060134c5dcf' }
  let(:token) { '660f899ecec3091074cc828dde2a2bcd' }
  let(:cookie) { "mp_#{token}_mixpanel=%7B%22distinct_id%22%3A%22#{distinct_id}%22%2C%22%24initial_referrer%22%3A%22%24direct%22%2C%22%24initial_referring_domain%22%3A%22%24direct%22%7D" }

  subject { Rack::MockRequest.new(app).get('/', 'HTTP_COOKIE' => cookie) }

  describe 'env.distinct_id' do
    # An app that returns env['mixpanel.distinct_id'] in the body
    let(:distinct_id_app) do
      lambda { |env| [200, {'Content-Type' => 'text/plain'}, [env['mixpanel.distinct_id']]] }
    end
    context 'when a token is set in the app' do
      let(:app) { Rack::Mixpanel.new(distinct_id_app, token) }
      context 'and a cookie is set' do
        its(:body) { should == distinct_id }
      end
      context 'and a cookie is not set' do
        let(:cookie) { '' }
        its(:body) { should == '' }
      end
    end

    context 'when a token is set in the environment' do
      let(:app) { Rack::Mixpanel.new(distinct_id_app) }
      before { ENV['MIXPANEL_API_TOKEN'] = token }
      context 'and a cookie is set' do
        its(:body) { should == distinct_id }
      end
      context 'and a cookie is not set' do
        let(:cookie) { '' }
        its(:body) { should == '' }
      end
    end
  end

  describe 'env.tracker' do
    # An app that returns the response from the env['mixpanel.track'].track call
    # and the track call's request thread
    let(:tracker_app) do
      lambda do |env|
        res = env['mixpanel.tracker'].track(event, properties)
        val = env['mixpanel.tracker'].thread.value
        [200, {'Content-Type' => 'text/plain'}, [res.nil?, "\n", val]]
      end
    end
    let(:event) { 'signup' }
    let(:properties) { {'gender' => 'male', 'age' => 45} }
    let(:app) { Rack::Mixpanel.new(tracker_app, token) }
    it 'sends a request to Mixpanel' do
      props = {
        'event' => event,
        'properties' => {
          'token' => token,
          'ip' => nil,
          'distinct_id' => distinct_id
        }.merge(properties)
      }
      enc_params = Base64.encode64 JSON.generate(props)
      query = URI.encode_www_form(:data => enc_params)
      uri = URI('https://api.mixpanel.com/track')
      uri.query = query
      FakeWeb.register_uri(:get, uri, :body => '1')
      subject.body.split("\n").should == ['true', '1']
    end
  end
end
