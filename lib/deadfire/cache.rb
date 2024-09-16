require 'sqlite3'

module Deadfire
  class Cache
    TABLE_NAME = "mixins"

    def initialize(db_path = "data/deadfire.db")
      @db = SQLite3::Database.new(db_path)
      create_table unless tables_exist?
    end

    def fetch(key)
      result = @db.execute("SELECT value, expires_at FROM  #{TABLE_NAME} WHERE key = ?", key).first
      return nil unless result && Time.parse(result[1]) > Time.now
      result[0]
    end

    def write(key, value, expires_in: 3600)
      expires_at = Time.now + expires_in
      @db.execute("REPLACE INTO #{TABLE_NAME} (key, value, expires_at) VALUES (?, ?, ?)", key, value, expires_at.to_s)
    end

    private

    def create_table
      @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS #{TABLE_NAME} (
          id INTEGER PRIMARY KEY,
          key TEXT NOT NULL UNIQUE,
          value TEXT,
          expires_at DATETIME
        );
      SQL
    end

    def tables_exist?
      tables = @db.execute <<-SQL
        SELECT name FROM sqlite_master WHERE type="table" AND name="#{TABLE_NAME}";
      SQL
      !tables.empty?
    end
  end
end