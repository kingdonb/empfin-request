require "application_system_test_case"

class EmptiesTest < ApplicationSystemTestCase
  setup do
    @empty = empties(:one)
  end

  test "visiting the index" do
    visit empties_url
    assert_selector "h1", text: "Empties"
  end

  test "creating a Empty" do
    visit empties_url
    click_on "New Empty"

    click_on "Create Empty"

    assert_text "Empty was successfully created"
    click_on "Back"
  end

  test "updating a Empty" do
    visit empties_url
    click_on "Edit", match: :first

    click_on "Update Empty"

    assert_text "Empty was successfully updated"
    click_on "Back"
  end

  test "destroying a Empty" do
    visit empties_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Empty was successfully destroyed"
  end
end
