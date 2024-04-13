class UsersController < ApplicationController

  def show
    # * （技術的な補足: params[:id]は文字列型の"1"ですが、findメソッドでは自動的に整数型に変換される）
    @user = User.find(params[:id])
    # binding.pry
    # debugger
  end

  def new
    @user = User.new
  end

  def create
    # @user = User.new(params[:user])
    @user = User.new(user_params)
    # * 上記は下記と同じ意味
    # @user = User.new(name: "Foo Bar", email: "foo@invalid",
    # password: "foo", password_confirmation: "bar")
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      # * 新しく作成されたユーザーのプロフィールページにリダイレクトする
      redirect_to @user
    else
      flash[:error] = "Something went wrong"
      # * 422 Unprocessable Entityに対応するもので、Turboを用いて通常のHTMLをレンダリングする場合に必要です。
      render 'new', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end
end
