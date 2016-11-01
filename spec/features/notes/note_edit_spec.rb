include Warden::Test::Helpers
Warden.test_mode!

feature 'Note edit', :js do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'user can edit own note' do
    user = FactoryGirl.create(:user)
    other_user = FactoryGirl.create(:user, :email => "other@email.com", :name => 'Other User')
    note = FactoryGirl.create(:note, :user_id => user.id)
    login_as(user, :scope => :user)
    visit edit_note_path(note)
    fill_in 'Content', :with => 'Updated content.'
    fill_in 'Visible to', :with => 'Other User'
    click_button 'save'
    expect(page).to have_content 'Edited note.'
    note.reload
    expect(note.readers).to include(other_user)
    expect(note.content).to eq('Updated content.')
  end

  scenario "user cannot edit another user's note" do
    user = FactoryGirl.create(:user)
    other_user = FactoryGirl.create(:user, :email => "other@email.com", :name => 'Other User')
    note = FactoryGirl.create(:note, :user_id => other_user.id)
    login_as(user, :scope => :user)
    visit edit_note_path(note)
    expect(page).to have_content 'Access denied.'
  end

  scenario "moderator cannot edit another user's note" do
    user = FactoryGirl.create(:user, :moderator)
    other_user = FactoryGirl.create(:user, :email => "other@email.com", :name => 'Other User')
    note = FactoryGirl.create(:note, :user_id => other_user.id)
    login_as(user, :scope => :user)
    visit edit_note_path(note)
    expect(page).to have_content 'Access denied.'
  end

  scenario "admin can edit another user's note" do
    user = FactoryGirl.create(:user, :moderator)
    other_user = FactoryGirl.create(:user, :email => "other@email.com", :name => 'Other User')
    note = FactoryGirl.create(:note, :user_id => user.id)
    login_as(user, :scope => :user)
    visit edit_note_path(note)
    fill_in 'Content', :with => 'Updated content.'
    fill_in 'Visible to', :with => 'Test User'
    click_button 'save'
    expect(page).to have_content 'Edited note.'
    note.reload
    expect(note.readers).to include(user)
    expect(note.content).to eq('Updated content.')
  end

end