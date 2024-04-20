class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # @micropostは新規投稿用の変数
      @micropost  = current_user.microposts.build
      # feedとは自分の投稿のことですでに存在する投稿
      @feed_items = current_user.feed.paginate(page: params[:page])
      # binding.pry
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
