class Routine
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Voteable
  key :title, String
  key :purpose, String
  key :resources, String
  key :weeks, Integer
  key :days, Array
  key :hours, Integer
  key :minutes, Integer
  key :start_date, String
  key :tags, Array
  key :parent, Routine
  key :changes, String
  key :user_id, ObjectId
  key :score, Integer, :default => 0
  belongs_to :mmuser
  many :comments
  def total_time_hours
    (self.weeks*self.days.count*(self.hours*60+self.minutes)/60).round
  end
  def total_time_minutes
    self.weeks*self.days.count*(self.hours*60+self.minutes)%60
  end
  def on_add_vote(vote)
    puts "voted"
  end
end

class Comment
  include MongoMapper::EmbeddedDocument
  key :content, String, :required => true 
  key :commentor, ObjectId, :required => true
  key :commentor_name, String
  many :comments 
  key :created_at, Time  

  belongs_to :commenter, :polymorphic => true
  
  private
  
  def set_created_at
    created_at = Time.now
    save! unless new_record?
  end
end

class Tag
  include MongoMapper::Document
  key :name, String, :unique
  key :description
end

class MmUser
  attr_accessible :token, :password, :password_confirmation, :email
  key :token, String
  key :score, Integer, :default => 0
  key :name, String, :default => "unknown"
  many :Routines
  many :Comments

  def validated?
    self.token == 'confirmed'
  end
end
