# Site Configuration, global permissions, etc..
#
# You must have the plugin installed
class Site < ActiveRecord::Base
  acts_as_logoable

  def self.current
    first || create
  end

  # Nice format email address for the Site
  def email_with_name
    "#{ name } <#{ email }>"
  end

  # HTTP protocol based on SSL setting
  def protocol
    "http#{ ssl? ? 's' : nil }"
  end

  # Domain http url considering protocol
  def domain_with_protocol
    "#{ protocol }://#{ domain }"
  end
end
