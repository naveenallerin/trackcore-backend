require 'rails_helper'

RSpec.describe "Api::V1::Templates", type: :request do
  let(:valid_attributes) { { name: "Sample Template", body: "Hello {{NAME}}" } }
  let(:invalid_attributes) { { name: "", body: "" } }

  describe "GET /api/v1/templates" do
    it "returns a successful response" do
      create(:template)
      get api_v1_templates_path
      expect(response).to be_successful
      expect(JSON.parse(response.body)).not_to be_empty
    end
  end

  describe "GET /api/v1/templates/:id" do
    it "returns a successful response" do
      template = create(:template)
      get api_v1_template_path(template)
      expect(response).to be_successful
    end

    it "returns not found for non-existent template" do
      get api_v1_template_path(id: 999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/templates" do
    context "with valid parameters" do
      it "creates a new Template" do
        expect {
          post api_v1_templates_path, params: { template: valid_attributes }
        }.to change(Template, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Template" do
        expect {
          post api_v1_templates_path, params: { template: invalid_attributes }
        }.to change(Template, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH/PUT /api/v1/templates/:id" do
    context "with valid parameters" do
      let(:new_attributes) { { name: "Updated Template" } }

      it "updates the requested template" do
        template = create(:template)
        patch api_v1_template_path(template), params: { template: new_attributes }
        template.reload
        expect(template.name).to eq("Updated Template")
        expect(response).to be_successful
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity response" do
        template = create(:template)
        patch api_v1_template_path(template), params: { template: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/templates/:id" do
    it "destroys the requested template" do
      template = create(:template)
      expect {
        delete api_v1_template_path(template)
      }.to change(Template, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
