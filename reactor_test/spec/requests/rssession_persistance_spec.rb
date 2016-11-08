require 'spec_helper'

describe "RSession persistance" do
  [:marshal, :hybrid, :json].each do |serialization_scheme|
    context "with #{serialization_scheme} cookie serialization" do
      before do
        Rails.application.config.action_dispatch.cookies_serializer = :serialization_scheme
      end

      it "returns empty response without user" do
        get "/login"
        expect(response.body).to be_blank
      end

      context "with root user" do
        it "persists the user in the session" do
          post "/login", user_name: "root"
          expect(response).to be_ok

          get "/login"
          expect(response.body).to eq("root")
        end
      end

      context "with non_root user" do
        it "persists the user in the session" do
          post "/login", user_name: "non_root"
          expect(response).to be_ok

          get "/login"
          expect(response.body).to eq("non_root")
        end
      end
    end
  end
end
