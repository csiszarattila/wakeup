require 'rubygems'
require 'sinatra'
require 'activerecord'

ActiveRecord::Base.establish_connection( 
  :adapter=>"sqlite3", :database=>"blog.sqlite3.db"
)

class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post 
end

get '/' do
  @posts = Post.all()
  haml :index
end

get '/posts/new' do
  @post = Post.new()
	haml :post_new
end

post '/posts' do
  Post.create(:title=>params[:title], :body=>params[:body]).save
  redirect '/'
end

get '/rss' do
  @posts = Post.all({:order=>"created_at DESC"})
  content_type 'application/xml', :charset => 'utf-8'
  
  builder({:layout=>false}) do |xml|
		xml.instruct! :xml, :version => '1.0'
		xml.rss :version => "2.0", "xmlns:atom"=>"http://www.w3.org/2005/Atom" do
			xml.channel do
				xml.title "Rubysztán"
				xml.description "Minden ami Ruby."
				xml.link "http://0.0.0.0:4567/"
				xml.atom :link, 
												:href	=>	"http://0.0.0.0:4567/rss",
												:rel	=>	"self",
												:type	=>	"application/rss+xml"
			
				@posts.each do |post|
					xml.item do
  					xml.title post.title
  					xml.link "/posts/#{post.id}"
  					xml.description post.body
  					xml.pubDate Time.parse(post.created_at.to_s).rfc822()
  					xml.guid "/posts/#{post.id}"
					end
				end
			end
		end
	end
end


get '/posts/:id/edit' do
  @post = Post.find(params[:id])
	haml :post_edit
end

get '/posts/:id' do
  @post = Post.find(params[:id])
  haml :post_show
end


put '/posts/:id' do
  Post.find(params[:id]).update_attributes(:title=>params[:title], :body=>params[:body])
  redirect "/posts/#{params[:id]}"
end

get '/posts/:id/delete' do
  Post.find(params[:id]).destroy
  redirect '/'
end

post '/posts/:id/comments' do
  Comment.create(:post_id=>params[:id], :email=>params[:email], :body=>params[:body])
  redirect "/posts/#{params[:id]}"
end

use_in_file_templates!

__END__

@@ layout
!!! Strict
%head
  %title Sinatra - I did it my way
%body
  %h1 
    %a{:href=>"/"} Sinatra - I did it my way
  = yield

@@ index
-for post in @posts
  %h2
    %a{:href=>"/posts/#{post.id}"}= post.title
    %a{:href=>"/posts/#{post.id}/edit"} / Edit
    %a{:href=>"/posts/#{post.id}/delete"} / Destroy
%a{:href=>"/posts/new"} Add a new post!
%a{:href=>"rss"} RSS

@@ post_show
%h2= @post.title
#body= @post.body
- @post.comments.each do |comment|
  %comment
    %p= "#{comment.email} @ #{comment.created_at}"
    %div= comment.body 
%h3 Please, comment it!
%form{:action=>"/posts/#{@post.id}/comments", :method=>"post"}
  %label{:for=>"email"}E-mail
  %input{:type=>"text", :name=>"email"}
  %label{:for=>"body"} Comment
  %textarea{:name=>"body"}
  %input{:type=>"submit", :value=>"Comment it!"}

@@ post_new
%form{:action=>"/posts", :method=>"post"}
  = haml :post_form, :layout=>false
  %input{:type=>"submit", :value=>"Post it!"}

@@ post_edit
%form{:action=>"/posts/#{@post.id}", :method=>"post"}
  = haml :post_form, :layout=>false
  %input{:type=>"hidden", :name=>"_method", :value=>"put"}
  %input{:type=>"submit", :value=>"Edit & Post it!"}
	
@@ post_form
%h1 Create a new post
%label Title
%input{:name=>"title", :type=>"text", :value=>@post.title}
%label Body
%textarea{:name=>"body"}= @post.body