class Users::BaseUserController < BaseController
  before_action :correct_user

  private

  # ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ before_action（権限関連） ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  # ユーザーがログイン済みユーザーであればtrueを返す。
  def current_user?(user)
    user == current_user
  end

  # 管理権限者、または現在ログイン済みユーザーを許可
  def admin_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
    return if current_user?(@user) || current_user.admin?

    # flash[:danger] = '権限がありません。'
    redirect_to root_path
  end

  def correct_user
    @user = if params[:user_id].present?
              User.find(params[:user_id])
            else
              User.find(params[:id])
            end

    return if current_user?(@user)

    counseling_id = params[:counseling_id] || params[:id]
    counseling = Counseling.find_by(id: counseling_id)

    if counseling && counseling.project.users.include?(current_user)
      return
    end

    flash[:danger] = t('flash.not_logined')
    redirect_to new_user_session_path
  end
end
