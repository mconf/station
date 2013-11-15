# Require Ruby URI Module, not defined by this file but with the
# same source file name
URI

{ 'atom/service' => 'AtomPub service document' }.each_pair do |gem, support|
  begin
    require gem
  rescue MissingSourceFile
    Rails.logger.info "Station Info: You need '#{ gem }' gem for #{ support } support"
  end
end

# URI storage in the database
class Uri < ActiveRecord::Base

  # Return this URI string
  def to_s
    self.uri
  end

  def to_uri
    @to_uri ||= ::URI.parse(self.uri)
  end

  # Dereference URI and return HTML document
  def html
    # NOTE: Must read StringIO or Tmpfile
    @html ||= Station::Html.new(dereference(:accept => 'text/html').try(:read))
  end

  def dereference(options = {})
    headers = {}
    headers['Accept'] = options[:accept] if options.key?(:accept)

    to_uri.open(headers)
  rescue
    nil
  end

  delegate :hcard, :hcard?,
           :to => :html

end
