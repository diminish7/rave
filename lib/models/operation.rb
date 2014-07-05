module Rave
  module Models
    # Represents an operation to be applied on the server.
    class Operation # :nodoc:
      attr_reader :index, :property

      def type; @type.dup; end
      def wave_id; @wave_id.dup; end
      def wavelet_id; @wavelet_id.dup; end
      def blip_id; @blip_id.dup; end

      JAVA_CLASS = 'com.google.wave.api.impl.OperationImpl' # :nodoc:

      #Constants
      # Types of operations
      WAVELET_APPEND_BLIP = 'WAVELET_APPEND_BLIP'
      WAVELET_ADD_PARTICIPANT = 'WAVELET_ADD_PARTICIPANT'
      WAVELET_REMOVE_PARTICIPANT = 'WAVELET_REMOVE_PARTICIPANT'
      WAVELET_CREATE = 'WAVELET_CREATE'
      WAVELET_REMOVE_SELF = 'WAVELET_REMOVE_SELF'
      WAVELET_DATADOC_SET = 'WAVELET_DATADOC_SET'
      WAVELET_SET_TITLE = 'WAVELET_SET_TITLE'
      BLIP_CREATE_CHILD = 'BLIP_CREATE_CHILD'
      BLIP_DELETE = 'BLIP_DELETE'
      DOCUMENT_ANNOTATION_DELETE = 'DOCUMENT_ANNOTATION_DELETE'
      DOCUMENT_ANNOTATION_SET = 'DOCUMENT_ANNOTATION_SET'
      DOCUMENT_ANNOTATION_SET_NORANGE = 'DOCUMENT_ANNOTATION_SET_NORANGE'
      DOCUMENT_APPEND = 'DOCUMENT_APPEND' # Plain text
      DOCUMENT_APPEND_MARKUP = 'DOCUMENT_APPEND_MARKUP' # HTML
      DOCUMENT_APPEND_STYLED_TEXT = 'DOCUMENT_APPEND_STYLED_TEXT'
      DOCUMENT_INSERT = 'DOCUMENT_INSERT'
      DOCUMENT_DELETE = 'DOCUMENT_DELETE'
      DOCUMENT_REPLACE = 'DOCUMENT_REPLACE'
      DOCUMENT_ELEMENT_APPEND = 'DOCUMENT_ELEMENT_APPEND'
      DOCUMENT_ELEMENT_DELETE = 'DOCUMENT_ELEMENT_DELETE'
      DOCUMENT_ELEMENT_INSERT = 'DOCUMENT_ELEMENT_INSERT'
      DOCUMENT_ELEMENT_INSERT_AFTER = 'DOCUMENT_ELEMENT_INSERT_AFTER'
      DOCUMENT_ELEMENT_INSERT_BEFORE = 'DOCUMENT_ELEMENT_INSERT_BEFORE'
      DOCUMENT_ELEMENT_REPLACE = 'DOCUMENT_ELEMENT_REPLACE'
      DOCUMENT_INLINE_BLIP_APPEND = 'DOCUMENT_INLINE_BLIP_APPEND'
      DOCUMENT_INLINE_BLIP_DELETE = 'DOCUMENT_INLINE_BLIP_DELETE'
      DOCUMENT_INLINE_BLIP_INSERT = 'DOCUMENT_INLINE_BLIP_INSERT'
      DOCUMENT_INLINE_BLIP_INSERT_AFTER_ELEMENT = 'DOCUMENT_INLINE_BLIP_INSERT_AFTER_ELEMENT'

      #Options include:
      # - :type
      # - :wave_id
      # - :wavelet_id
      # - :blip_id
      # - :index
      # - :property
      def initialize(options = {})
        @type = options[:type]
        @wave_id = options[:wave_id]
        @wavelet_id = options[:wavelet_id] || ''
        @blip_id = options[:blip_id] || ''
        @index = options[:index] || -1
        #Convert property to a rave hash if possible (to better serialize to json later)
        @property = (property = options[:property]).respond_to?(:to_rave_hash) ? property.to_rave_hash : property
      end

      #Serialize the operation to json
      def to_json
        hash = {
          'blipId' => @blip_id,
          'index' => @index,
          'waveletId' => @wavelet_id,
          'waveId' => @wave_id,
          'type' => @type,
          'javaClass' => JAVA_CLASS
        }

        hash['property'] = @property unless @property.nil?

        hash.to_json
      end
    end
  end
end

