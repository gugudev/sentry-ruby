require "spec_helper"

require "raven/context_filter"

RSpec.describe Raven::ContextFilter do
  context "filters out ActiveJob keys from context" do
    let(:context) do
      { :_aj_globalid => GlobalID.new("gid://app/model/id"), :key => "value" }
    end
    let(:expected_context) do
      { :key => "value" }
    end

    it "removes reserved keys" do
      new_context = described_class.filter(context)

      expect(new_context).to eq(expected_context)
    end
  end

  context "filters out ActiveJob keys from nested context" do
    let(:context) do
      {
        :_aj_globalid => GlobalID.new("gid://app/model/id"),
        :arguments => { "key" => "value", "_aj_symbol_keys" => ["key"] }
      }
    end
    let(:expected_context) do
      {
        :arguments => { "key" => "value" }
      }
    end

    it "removes reserved keys" do
      new_context = described_class.filter(context)

      expect(new_context).to eq(expected_context)
    end
  end
end
