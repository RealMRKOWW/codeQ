require_relative '../acceptance_helper'

feature 'User can delete answer', %q{
  As an author of answer
  I'd like to be able delete my answer
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given!(:answer) { create(:answer, question: question1, user: user1) }
  given(:question2) { create(:question, user: user1) }
  given!(:answers) { create_list(:answer, 5, question: question2) }

  describe 'Auth user try delete his answer' do
    before do
      sign_in(user1)
      visit question_path(question1)
    end

    scenario 'see delete link' do
      expect(page).to have_link 'Delete answer'
    end

    scenario 'delete his answer', js: true do
      click_on 'Delete answer'

      expect(current_path).to eq question_path(question1)
      expect(page).to_not have_content answer.body
      expect(page).to have_content 'Your answer was successfully destroyed.'
    end
  end


  scenario 'Auth user cannot delete not his answer' do
    sign_in(user2)

    visit question_path(question1)

    expect(page).to_not have_content 'Delete answer'
  end

  scenario 'Guest cannot delete any answer' do
    visit question_path(question1)

    expect(page).to_not have_content 'Delete answer'
  end

end