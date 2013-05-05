class ApiKey < ActiveRecord::Base
  belongs_to :user #declares that users hold api keys
  before_create :generate_access_token #creates api key function needs to be called

private
  
  #code for the creation of an api key's access token
  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

end
