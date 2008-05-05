module Learning::Views
  def layout
    self << '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' + "\n" 
    html {
      head {
        title(@title)
        link :rel => 'alternate', :type => 'application/atom+xml', :title => 'learning.kicks-ass.org -- Atom', :href => R(Feed, 'atom')
        @css.each do |c|
          _css_include(c)
        end
        script { "var $session = #{@js_session.to_json};" }
        @js.each do |j|
          _js_include(j)
        end
      }
      body {
        yield
      }
    }
  end

  def _js_include(j)
    script :src => j
  end

  def _css_include(c)
    if c.is_a? String
      link :type => 'text/css', :href => c, :rel => 'stylesheet', :media => 'all'
    else
      link :type => 'text/css', :href => c[:href], :rel => 'stylesheet', :media => c[:media] || 'all'
    end
  end  

  def home
    img.spinner! :src => '/static/images/spinner.gif', :style => 'display: none'
    form.learning(:method => 'post', :action => R(Pair)) {
      h1 {
        span('Everything I know about ')
        input.text.topic! :type => 'text', :name => 'topic', :size => 17, :value => @topic
        span(',')
      }
      h1 {
        span('I learned from ')
        input.text.teacher! :type => 'text', :name => 'teacher', :size => 17, :value => @teacher
        span('.')
      }
      input.post.button   :type => 'submit', :name => 'submit', :value => 'POST'
      input.random.button :type => 'submit', :name => 'submit', :value => 'RANDOM'
    }
    table.learned {
      tbody {
        @pairs.each do |p|
          tr {
            td {
              a(p.id, :href => R(Pair, p.id, p.slug))
            }
            td.topic {
              span "Everything I know about " 
              a.topic(p.topic.word, :href => "http://www.google.com/search?q=#{p.topic.word}")
              span ", "
            }
            td.teacher {
              span "I learned from "
              a.teacher(p.teacher.word, :href => "http://www.google.com/search?q=#{p.teacher.word}")
              span "."
            }
            td.hits(p.hits) 
            td.date(p.created_at.strftime('%Y-%m-%d'), :title => 'YYYY-MM-DD Makes Sense')
          }
        end
      }
    }
  end

  def pair
    div.learning {
      h1 {
        span('Everything I know about ')
        span.phrase @pair.topic.word
        span(',')
      }
      h1 {
        span('I learned from ')
        span.phrase @pair.teacher.word
        span('.')
      }
      h4 {
        a("Everything I know about X, I learned from Y.", :href => R(Home))
      }
    }
  end

  # @forum
  # - name
  # - url
  # - feed_url
  # @threads = [ ]
  # - title
  # - url
  # - unique_id
  # - updated_at
  # - author
  # - content
  def _atom_feed
    output = ""
    xml = Builder::XmlMarkup.new(:indent => 2, :target => output)
    xml.instruct!
    xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
      xml.title   @forum.name
      xml.link    "rel" => "alternate", "href" => @forum.url
      xml.link    "rel" => "self",      "href" => @forum.feed_url
      xml.id      @forum.url
      xml.updated DateTime.now.strftime('%FT%T%z')
      xml.author  { xml.name 'Heath Row' }
      @threads.each do |thread|
        xml.entry do
          xml.title   thread.title
          xml.link    "rel" => "alternate", "href" => thread.url
          xml.id      thread.unique_id
          xml.updated thread.updated_at.strftime('%FT%T%z')
          xml.author  do
            xml.name  thread.author
          end
          xml.content "type" => "html" do
            xml.text! thread.content + "\n"
          end
        end
      end
    end
    output
  end

  def env
    pre {
      @env.keys.sort.each do |k|
        span("#{k}=#{@env[k]}\n")
      end
    }
  end

end
