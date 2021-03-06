require_relative '../acceptance_helper'

feature 'Guest can sign up', %q{
  In order to write questions
  As an guest
  I want to be able sign up
} do
  given!(:user) { create(:user) }
  given(:new_user) { build(:user) }

  describe 'Guest try' do
    scenario 'with valid registered data' do
      visit root_path
      click_on 'Sign Up'

      fill_in 'Email', with: new_user.email
      fill_in 'Password', with: new_user.password
      fill_in 'Password confirmation', with: new_user.password
      click_button 'Sign up'

      expect(page).to have_content I18n.t('devise.registrations.signed_up')
    end

    scenario 'with invalid registered data' do
      visit root_path
      click_on 'Sign Up'

      click_button 'Sign up'

      expect(page).to have_content 'Email can\'t be blank'
    end

    scenario 'with existing user' do
      visit root_path

      click_on 'Sign Up'

      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      fill_in 'Password confirmation', with: user.password
      click_button 'Sign up'

      expect(page).to have_content 'Email has already been taken'
    end
  end
end