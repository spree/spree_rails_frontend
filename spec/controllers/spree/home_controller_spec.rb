require 'spec_helper'

describe Spree::HomeController, type: :controller do
  context 'layout' do
    it 'renders default layout' do
      get :index
      expect(response).to render_template(layout: 'spree/layouts/spree_application')
    end

    context 'when http_cache_enabled is set to true' do
      before do
        allow(Spree::Frontend::Config).to receive(:[]).with(anything).and_call_original
        allow(Spree::Frontend::Config).to receive(:[]).with(:http_cache_enabled).and_return(true)
      end

      it 'calls fresh_when method' do
        expect(subject).to receive(:fresh_when)

        get :index
      end
    end

    context 'different layout specified in config' do
      before do
        allow(Spree::Frontend::Config).to receive(:[]).with(anything).and_call_original
        allow(Spree::Frontend::Config).to receive(:[]).with(:layout).and_return('layouts/application')
      end

      it 'renders specified layout' do
        get :index
        expect(response).to render_template(layout: 'layouts/application')
      end
    end

    context 'when http_cache_enabled is set to false' do
      it 'does not call fresh_when method' do
        expect(subject).not_to receive(:fresh_when)

        get :index
      end
    end
  end
end
