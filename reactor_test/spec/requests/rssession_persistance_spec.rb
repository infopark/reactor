require 'spec_helper'

describe "RSession persistance" do
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
