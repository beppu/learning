module Learning::Controllers
  # http://code.whytheluckystiff.net/camping/wiki/ServingStaticFiles
  class Static < R '/static/(.+)'
    MIME_TYPES = {
      '.html' => 'text/html',
      '.css'  => 'text/css',
      '.js'   => 'text/javascript',
      '.jpg'  => 'image/jpeg',
      '.gif'  => 'image/gif'
    }
    PATH = File.expand_path(File.dirname(File.dirname(__FILE__)))

    def get(path)
      @headers['Content-Type'] = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain" 
      unless path.include? ".." # prevent directory traversal attacks
        @headers['X-Sendfile'] = "#{PATH}/static/#{path}" 
      else
        @status = "403" 
        "403 - Invalid path" 
      end
    end
  end

  class Home < R '/'
    def get
      @topic = @teacher = ""
      @pairs = L.Pair.find(
        :all,
        :order => 'updated_at DESC, created_at DESC',
        :limit => 100
      )
      render :home
    end
  end

  class Env < R '/env'
    def get
      render :env
    end
  end

  class Feed < R '/(\w+).xml'
    def get(format='atom')
      @forum   = OpenStruct.new(
        :name     => 'Everything I know about X, I learned from Y',
        :url      => "http://#{@env['HTTP_HOST']}/",
        :feed_url => "http://#{@env['HTTP_HOST']}" + R(Feed, format)
      )
      @pairs = L.Pair.find(
        :all,
        :order => 'updated_at DESC, created_at DESC',
        :limit => 400
      )
      @threads = [ ]
      @pairs.each do |p|
        thread = OpenStruct.new(
          :author     => 'Anonymous',
          :title      => "#{p.topic.word} and #{p.teacher.word}",
          :url        => "http://#{@env['HTTP_HOST']}" + R(Pair, p.id, p.slug),
          :unique_id  => "tag:#{@env['HTTP_HOST']},#{p.created_at.strftime('%F')}:#{R(Pair, p.id, p.slug)}",
          :updated_at => p.updated_at,
          :content    => "<h1>Everything I know about #{p.topic.word},</h1><h1>I learned from #{p.teacher.word}.</h1>"
        )
        @threads << thread
      end
      template = "_#{format}_feed"
      render template.to_sym
    end
  end

  class Random < R '/random(\.\w+)?'
    def get(format = nil)
      topic_count = L.Topic.count
      teacher_count = L.Teacher.count
      topic = nil
      teacher = nil
      if topic_count > 0
        while topic.nil?
          begin
            topic = L.Topic.find(rand(topic_count) + 1)
          rescue
          end
        end
        @topic = topic.word
      else
        @topic = ""
      end
      if teacher_count > 0
        while teacher.nil?
          begin
            teacher = L.Teacher.find(rand(teacher_count) + 1)
          rescue
          end
        end
        @teacher = teacher.word
      else
        @teacher = ""
      end
      if format == '.json'
        return { :topic => @topic, :teacher => @teacher }.to_json
      end
      @pairs = L.Pair.find(
        :all,
        :order => 'updated_at DESC, created_at DESC',
        :limit => 100
      )
      render :home
    end
  end

  class Pair < R '/proverb', '/proverb/(\d+)', '/proverb/(\d+)_.oOo._(.*)'
    def get(pair_id, slug=nil)
      @pair = L.Pair.find(pair_id)
      render :pair
    end
    def post(pair_id=nil, slug=nil)
      @state.errors = [ ]
      if input.submit == "RANDOM"
        redirect R(Random, nil)
        return
      end
      if input.topic.empty?
        @state.errors.push "You need to have learned something."
      end
      if input.teacher.empty?
        @state.errors.push "You must've learned this somehow."
      end
      if @state.errors.length == 0
        topic   = L.Topic.find_or_create_by_word(input.topic.strip)
        teacher = L.Teacher.find_or_create_by_word(input.teacher.strip)
        pair    = L.Pair.find(
          :first,
          :conditions => [ 'topic_id = ? AND teacher_id = ?', topic.id, teacher.id ]
        )
        if pair.nil?
          L.Pair.create(:topic_id => topic.id, :teacher_id => teacher.id)
        else
          pair.hits += 1
          pair.save
        end
      end
      @cgi_cookies[topic.word] = { 
        :value   => topic.word,
        :secure  => true
      }
      @cgi_cookies[teacher.word] = { 
        :value   => teacher.word, 
        :secure  => false,
        :expires => Time.now + 4.years
      }
      redirect R(Home)
    end
  end
end
