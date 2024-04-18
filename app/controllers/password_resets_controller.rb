class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  # * パスワード再設定の有効期限が切れていないかどうかを確認する
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new', status: :unprocessable_entity
    end
  end

  # ページを表示させるだけのため、特に処理は不要
  def edit
    # before_action で get_user と valid_user が呼ばれているため、ここでの処理は不要
  end

  # 再設定パスワードの更新処理
  def update
    # * 新しいパスワードと確認用パスワードが空文字列になっていないかへの対応
    if params[:user][:password].empty?
      # @user.errors.add(:password, "can't be empty")
      # * blankオプションを指定しておくと、rails-i18n gemで多言語化したときに、
      # * 対応する言語で適切なメッセージが表示されるというメリットがあります。 ※上記も可能
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
    # * 新しいパスワードが正しければ、更新するへの対応
    elsif @user.update(user_params)
      # * パスワードリセット時にユーザーセッションをすべて破棄する セッションハイジャック対策
      # - セッションハイジャックから保護するためには、パスワードがリセットされた際にセッショントークンを無効化する必要があります。
      # - セッショントークンはユーザーのログイン状態を保持するために使用されるため、このトークンを変更することで、
      # - 以前に盗まれたセッショントークンを使用している攻撃者からユーザーを保護することができます。
      #^ 20240418
      @user.forget # app/models/user.rb #remember_digestをnilに更新
      reset_session
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      # * 無効なパスワードであれば失敗させる（失敗した理由も表示する）
      render 'edit', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # beforeフィルタ

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    # * 正当なユーザーとは、そのユーザーが存在し、有効化され、認証が完了しているという意味です。
    def valid_user
      # パスワード再設定メールのリンクをクリックして有効化させる
      # <a href="http://localhost:3000/password_resets/1asTCLGJxG2XNRjV2ekkIQ/edit?email=hirotaka.aoki27%40gmail.com">Reset password</a>
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # 期限切れかどうかを確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end