class FixUtf8Support < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE posts MODIFY caption varchar(255) CHARACTER SET utf8 default NULL"
    execute "ALTER TABLE posts MODIFY summary text CHARACTER SET utf8 default NULL"
    execute "ALTER TABLE posts MODIFY body text CHARACTER SET utf8 default NULL"
    execute "ALTER TABLE links MODIFY caption varchar(255) CHARACTER SET utf8 default NULL"
    execute "ALTER TABLE links MODIFY url varchar(255) CHARACTER SET utf8 default NULL"
  end

  def self.down
  end
end
