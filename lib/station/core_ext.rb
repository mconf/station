unless Symbol.instance_methods.include? 'to_class'
  Symbol.class_eval do
    def to_class
      self.to_s.classify.constantize
    end
  end
end

# atom-tools like interface for standard Ruby RSS library
begin
  require 'rss/1.0'
  require 'rss/2.0'

  # AtomTools compatibility with Ruby RSS standard lib
  module RSS::AtomTools #:nodoc:
    module Feed
      def entries
        items
      end

      def title
        if @channel
          Atom::Text.new @channel.title
        else
          nil
        end
      end
    end

    module Entry
      def id
        respond_to?(:guid) && guid.present? ? guid.content : nil
      end

      def content
        return @content if @content

        @content = Atom::Text.new description
        @content.type = 'html'
        @content
      end

      def links
        return [] unless @link

        Array(Atom::Link.new :type => 'text/html', :rel => 'alternate', :href => @link)
      end

      def updated
        # Get rid of bug: https://rails.lighthouseapp.com/projects/8994/tickets/1701-argumenterror-in-time_with_zonerb146
        respond_to?(:pubDate) ? Time.parse(pubDate.to_s) : Time.now
      end

      def published
        # Get rid of bug: https://rails.lighthouseapp.com/projects/8994/tickets/1701-argumenterror-in-time_with_zonerb146
        respond_to?(:pubDate) ? Time.parse(pubDate.to_s) : Time.now
      end
    end
  end

  class RSS::Rss #:nodoc:
    include RSS::AtomTools::Feed
  end

  class RSS::RDF #:nodoc:
    include RSS::AtomTools::Feed
  end

  class RSS::Rss::Channel::Item #:nodoc:
    include RSS::AtomTools::Entry
  end

  class RSS::RDF::Item #:nodoc:
    include RSS::AtomTools::Entry
  end
rescue => e
  puts "Station Warning: RSS library missing"
  puts e
end
