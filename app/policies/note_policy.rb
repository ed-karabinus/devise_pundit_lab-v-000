class NotePolicy < ApplicationPolicy
  def index?
    user.admin? || user.moderator?
  end

  def show?
    user.admin? || user.moderator? || record.try(:user_id) == user.id || record.try(:readers).include?(user)
  end

  def update?
    user.admin? || record.try(:user_id) == user.id
  end

  def destroy?
    user.admin? || record.try(:user_id) == user.id
  end
end