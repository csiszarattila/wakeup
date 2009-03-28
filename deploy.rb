require 'rubygems'
require 'activerecord'
ActiveRecord::Base.establish_connection(
	:adapter => 'sqlite3',
	:dbfile	=>	'blog.sqlite3.db'
)

ActiveRecord::Schema.define(:version=>1) do
	create_table :posts do |t|
		t.string :title
		t.text :body
		t.datetime :created_at
	end
	
	create_table :comments do |t|
		t.string :email
		t.text :body
		t.datetime :created_at
		t.integer :post_id
	end
end