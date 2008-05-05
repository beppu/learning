module Learning::Models

  class Topic < Base
    has_many :pairs
  end

  class Teacher < Base
    has_many :pairs
  end

  class Pair < Base
    belongs_to :topic
    belongs_to :teacher

    def slug
      "#{topic.word}-and-#{teacher.word}"
    end
  end

end
