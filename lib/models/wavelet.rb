# Represents a Wavelet, owned by a Wave
module Rave
  module Models
    class Wavelet
      attr_reader :creator, :creation_time, :data_documents, :last_modified_time, 
                  :participants, :root_blip_id, :title, :version, :wave_id, :id
      
      # Options include:
      # - creator
      # - creation_time 
      # - data_documents
      # - last_modifed_time
      # - participants
      # - root_blip_id
      # - title
      # - version
      # - wave_id
      # - id
      def initialize(options = {})
        @creator = options[:creator]
        @creation_time = options[:creation_time] || Time.now
        @data_documents = options[:data_documents] || {}
        @last_modified_time = options[:last_modified_time] || Time.now
        @participants = Set.new(options[:participants])
        @root_blip_id = options[:root_blip_id]
        @title = options[:title]
        @version = options[:version] || 0
        @wave_id = options[:wave_id]
        @id = options[:id]
      end
      
    end
  end
end