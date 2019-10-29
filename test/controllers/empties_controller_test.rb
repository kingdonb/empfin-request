require 'test_helper'

class EmptiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @empty = empties(:one)
  end

  test "should get index" do
    get empties_url
    assert_response :success
  end

  test "should get new" do
    get new_empty_url
    assert_response :success
  end

  test "should create empty" do
    assert_difference('Empty.count') do
      post empties_url, params: { empty: {  } }
    end

    assert_redirected_to empty_url(Empty.last)
  end

  test "should show empty" do
    get empty_url(@empty)
    assert_response :success
  end

  test "should get edit" do
    get edit_empty_url(@empty)
    assert_response :success
  end

  test "should update empty" do
    patch empty_url(@empty), params: { empty: {  } }
    assert_redirected_to empty_url(@empty)
  end

  test "should destroy empty" do
    assert_difference('Empty.count', -1) do
      delete empty_url(@empty)
    end

    assert_redirected_to empties_url
  end
end
