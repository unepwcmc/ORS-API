require 'test_helper'

describe Api::V1::BaseController do
  describe "#test_exception_notifier" do
    it "should raise StandardError" do
      get :test_exception_notifier
      assert_raises StandardError
    end
  end
end
