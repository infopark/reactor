require 'spec_helper'

describe "RSession persistance", type: :request, focus: false do
  [:marshal, :hybrid, :json].each do |serialization_scheme|
    context "with #{serialization_scheme} cookie serialization" do
      before do
        Rails.application.config.action_dispatch.cookies_serializer = serialization_scheme
        # disable standard JSESSION cookie handling
        allow_any_instance_of(LoginsController).to receive(:rsession_auth)
      end

      it "returns empty response without user" do
        get "/login"
        expect(response.body).to be_blank
      end

      context "with root user" do
        it "persists the user in the session" do
          post "/login", params: {user_name: "root"}
          expect(response).to be_ok

          get "/login"
          expect(response.body).to eq("root")
        end
      end

      context "with non_root user" do
        it "persists the user in the session" do
          post "/login", params: {user_name: "non_root"}
          expect(response).to be_ok

          get "/login"
          expect(response.body).to eq("non_root")
        end
      end
    end
  end
end
