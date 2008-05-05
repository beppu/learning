module Learning::Models
  class InitialSchema < V 1
    def self.up
      # Everything I know about X...
      create_table :learning_topics do |t|
        t.column :created_at, :datetime, :null => false
        t.column :updated_at, :datetime
        t.column :word, :string, :null => false
      end
      add_index :learning_topics, :word, :unique => true

      # ... I learned from Y.
      create_table :learning_teachers do |t|
        t.column :created_at, :datetime, :null => false
        t.column :updated_at, :datetime
        t.column :word, :string, :null => false
      end
      add_index :learning_teachers, :word, :unique => true    

      # XY combinations
      create_table :learning_pairs do |t|
        t.column :created_at, :datetime, :null => false
        t.column :updated_at, :datetime
        t.column :topic_id, :integer, :null => false
        t.column :teacher_id, :integer, :null => false
        t.column :hits, :integer, :default => 1
      end
      add_index :learning_pairs, [:topic_id, :teacher_id], :unique => true    
    end
    def self.down
      drop_table :learning_topics
      drop_table :learning_teachers
      drop_table :learning_pairs
    end
  end
end
