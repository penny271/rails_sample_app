class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  # * このフィルターは、削除するマイクロポストが現在のユーザーに属していることを確認します。
  before_action :correct_user,   only: :destroy

  def create
    # .build は .new とほぼ同じ意味 associationを使って新しいオブジェクトを作成するときに使用する
    @micropost = current_user.microposts.build(micropost_params)
    # * 許可済み属性リストにimageを追加する (app/models/micropost.rb) Active Storage を使っている
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      # ! render なので、リクエストが送信されたときに、新しいリクエストが生成されるわけではない
      # ! つまり、再度 static_pages_controller の home アクションが呼び出されるわけではない
      # ! よって、@feed_itemsは nil になる
      # ! それを回避するために事前に feed を取得しておく
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # testだと root_url になっているが、リダイレクト先がリクエスト元になるように変更
    # if request.referrer.nil?
    #   redirect_to root_url, status: :see_other
    # else
    #   # request.referrerは、現在のリクエストが発生する直前にブラウザが訪れていたページのURLを指します。
    #   redirect_to request.referrer, status: :see_other
    # end
    redirect_back_or_to(root_url, status: :see_other) # * 上記の書き換え
  end

  private

    # * Strong Parameters で許可された属性だけを受け取る
    def micropost_params
      params.require(:micropost).permit(:content, :image) # * image を追加
    end

    # * 大きな違いは、User.findを使うのではなく、関連付けを経由してマイクロポストを検索する点です。
    # * これにより、ログインしているユーザーが他のユーザーのマイクロポストを削除することを防ぎます。
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?
    end
end