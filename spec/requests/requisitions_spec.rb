require 'rails_helper'

RSpec.describe "Requisitions", type: :request do
  let(:json_headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json'
    }
  end

  let(:valid_attributes) {
    {
      title: "Software Engineer",
      description: "Senior Ruby Developer position",
      status: "open"
    }
  }

  let(:invalid_attributes) {
    {
      title: "",
      description: "",
      status: "invalid_status"
    }
  }

  describe "GET /requisitions" do
    it "returns a successful response" do
      create(:requisition)
      get requisitions_path, headers: json_headers
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe "POST /requisitions" do
    context "with valid parameters" do
      it "creates a new Requisition" do
        expect {
          post requisitions_path, 
               params: { requisition: valid_attributes }.to_json,
               headers: json_headers
        }.to change(Requisition, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(/json/)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Requisition" do
        expect {
          post requisitions_path,
               params: { requisition: invalid_attributes }.to_json,
               headers: json_headers
        }.to change(Requisition, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /requisitions/:id" do
    it "returns a successful response" do
      requisition = create(:requisition)
      get requisition_path(requisition), headers: json_headers
      expect(response).to have_http_status(:success)
    end

    it "returns not found for non-existent requisition" do
      get requisition_path(id: 999999), headers: json_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH/PUT /requisitions/:id" do
    let(:requisition) { create(:requisition) }
    let(:new_attributes) { { title: "Updated Title" } }

    context "with valid parameters" do
      it "updates the requested requisition" do
        patch requisition_path(requisition),
              params: { requisition: new_attributes }.to_json,
              headers: json_headers
        expect(response).to have_http_status(:ok)
        requisition.reload
        expect(requisition.title).to eq("Updated Title")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity status" do
        patch requisition_path(requisition),
              params: { requisition: invalid_attributes }.to_json,
              headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /requisitions/:id" do
    it "destroys the requested requisition" do
      requisition = create(:requisition)
      expect {
        delete requisition_path(requisition), headers: json_headers
      }.to change(Requisition, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "returns not found for non-existent requisition" do
      delete requisition_path(id: 999999), headers: json_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
