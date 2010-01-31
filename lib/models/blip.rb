module Rave
  module Models
    # Represents a blip, containing formated text, gadgets and other elements.
    # It is part of a Wavelet within a Wave.
    class Blip < Component
      include Rave::Mixins::TimeUtils
      include Rave::Mixins::Logger
      
      JAVA_CLASS = 'com.google.wave.api.impl.BlipData' # :nodoc:

      # Version number of the contents of the blip [Integer]
      def version
        @version.dup
      end

      # Annotations on the blip [Array of Annotation]
      def annotations # :nodoc:
        @annotations.dup
      end

      # IDs of the children of this blip [Array of String]
      def child_blip_ids # :nodoc:
        @child_blip_ids.map { |id| id.dup }
      end

      # IDs (email addresses) of those who have altered this blip [Array of String]
      def contributor_ids # :nodoc:
        @contributor_ids.map { |id| id.dup }
      end

      # Elements contained within this blip [Array of Element]
      def elements # :nodoc:
        @elements.dup
      end

      # Last time the blip was altered [Time]
      def last_modified_time # :nodoc:
        @last_modified_time.dup
      end

      # ID of this blip's parent [String or nil for a root blip]
      def parent_blip_id # :nodoc:
        @parent_blip_id.nil? ? nil : @parent_blip_id.dup
      end

      # ID of the wave this blip belongs to [String]
      def wave_id # :nodoc:
        @wave_id.nil? ? nil : @wave_id.dup
      end

      # ID of the wavelet this blip belongs to [String]
      def wavelet_id # :nodoc:
        @wavelet_id.nil? ? nil : @wavelet_id.dup
      end

      # Wavelet that the blip is a part of [Wavelet]
      def wavelet # :nodoc:
        @context.wavelets[@wavelet_id]
      end

      # Wave that this blip is a part of [Wave]
      def wave # :nodoc:
        @context.waves[@wave_id]
      end

      # Blip that this Blip is a direct reply to. Will be nil if the root blip
      # in a wavelet [Blip or nil for a root blip]
      def parent_blip # :nodoc:
        @context.blips[@parent_blip_id]
      end

      # Returns true if this is a root blip (no parent blip) [Boolean]
      def root? # :nodoc:
        @parent_blip_id.nil?
      end

      # Returns true if this is a leaf node (has no children). [Boolean]
      def leaf? # :nodoc:
        @child_blip_ids.empty?
      end

      # Has the blip been deleted? [Boolean]
      def deleted? # :nodoc:
        [:deleted, :null].include? @state
      end

      # Has the blip been completely destroyed? [Boolean]
      def null? # :nodoc:
        @state == :null
      end

      # Text contained in the blip [String]
      def content # :nodoc:
        @content.dup
      end

      # Users that have made a contribution to the blip [Array of User]
      def contributors # :nodoc:
        @contributor_ids.map { |c| @context.users[c] }
      end

      # Original creator of the blip [User]
      def creator # :nodoc:
        @context.users[@creator]
      end

      # List of direct children of this blip. The first one will be continuing
      # the thread, others will be indented replies [Array of Blip]
      def child_blips # :nodoc:
        @child_blip_ids.map { |id| @context.blips[id] }
      end

      # Ensure that all elements within the blip are given a context.
      def context=(value) # :nodoc:
        super(value)
        @elements.each_value { |e| e.context = value }
      end

      VALID_STATES = [:normal, :null, :deleted] # :nodoc: As passed to initializer in :state option.
      
      #Options include:
      # - :annotations
      # - :child_blip_ids
      # - :content
      # - :contributors
      # - :creator
      # - :elements
      # - :last_modified_time
      # - :parent_blip_id
      # - :version
      # - :wave_id
      # - :wavelet_id
      # - :id
      # - :context
      # - :state
      def initialize(options = {}) # :nodoc:
        @annotations = options[:annotations] || []
        @child_blip_ids = options[:child_blip_ids] || []
        @content = options[:content] || ''
        @contributor_ids = options[:contributors] || []
        @creator = options[:creator] || User::NOBODY_ID
        @elements = options[:elements] || {}
        @last_modified_time = time_from_json(options[:last_modified_time]) || Time.now
        @parent_blip_id = options[:parent_blip_id]
        @version = options[:version] || -1
        @wave_id = options[:wave_id]
        @wavelet_id = options[:wavelet_id]
        @state = options[:state] || :normal

        unless VALID_STATES.include? @state
          raise ArgumentError.new("Bad state #{options[:state]}. Should be one of #{VALID_STATES.join(', ')}")
        end

        # If the blip doesn't have a defined ID, since we just created it,
        # assign a temporary, though unique, ID, based on the ID of the wavelet.
        if options[:id].nil?
          options[:id] = "#{GENERATED_PREFIX}_blip_#{unique_id}"
        end

        super(options)
      end
      
      #Returns true if an annotation with the given name exists in this blip
      def has_annotation?(name)
        @annotations.any? { |a| a.name == name }
      end

      # Adds an annotation to the Blip.
      def add_annotation(annotation)
        @annotations << annotation
        self
      end
      
      #Creates a child blip under this blip
      def create_child_blip
        blip = Blip.new(:wave_id => @wave_id, :parent_blip_id => @id, :wavelet_id => @wavelet_id,
          :context => @context, :contributors => [Robot.instance.id])
        @context.add_operation(:type => Operation::BLIP_CREATE_CHILD, :blip_id => @id, :wave_id => @wave_id, :wavelet_id => @wavelet_id, :property => blip)
        add_child_blip(blip)
        blip
      end

      # Adds a created child blip to this blip.
      def add_child_blip(blip) # :nodoc:
        @child_blip_ids << blip.id
        @context.add_blip(blip)
      end

      # INTERNAL
      # Removed a child blip.
      def remove_child_blip(blip) # :nodoc:
        @child_blip_ids.delete(blip.id)

        # Destroy oneself completely if you are no longer useful to structure.
        destroy_me if deleted? and leaf? and not root?
      end
      
      # Delete this blip from its wavelet.
      # Returns the blip id.
      def delete
        if deleted?
          logger.warning("Attempt to delete blip that has already been deleted: #{id}")
        elsif root?
          logger.warning("Attempt to delete root blip: #{id}")
        else
          @context.add_operation(:type => Operation::BLIP_DELETE,
            :blip_id => @id, :wave_id => @wave_id, :wavelet_id => @wavelet_id)
          delete_me
        end
      end

      # Convert to string.
      def to_s
        str = @content.gsub(/\n/, "\\n")
        str = str.length > 24 ? "#{str[0..20]}..." : str
        
        str = case @state
        when :normal
          "#{contributors.join(',')}:#{str}"
        when :deleted
          '<DELETED>'
        when :null
          '<NULL>'
        end

        "#{super}:#{str}"
      end

      # *INTERNAL*
      # Write out a formatted block of text showing the blip and its descendants.
      def print_structure(indent = 0) # :nodoc:
        str = "#{'  ' * indent}#{to_s}\n"

        unless @child_blip_ids.empty?
          # Move the first blip to the end, since it will be looked at last.
          blip_ids = @child_blip_ids
          blip_ids.push(blip_ids.shift)

          # All children, except the first, should be indented.
          blip_ids.each_with_index do |blip_id, index|
            is_last_blip = (index == blip_ids.size - 1)
            
            # All except the last one should be indented again.
            ind = is_last_blip ? indent : indent + 1
            blip = @context.blips[blip_id]
            if blip
              str << blip.print_structure(ind)
            else
              str << "#{'  ' * ind}<undefined-blip>:#{blip_id}\n"
            end

            str << "\n" unless is_last_blip # Gap between reply chains.
          end
        end

        str
      end

      # *INTERNAL*
      # Convert to json for sending in an operation. We should never need to
      # send more data than this, although blips we receive will have more data.
      def to_json # :nodoc:
        {
          'blipId' => @id,
          'javaClass' => JAVA_CLASS,
          'waveId' => @wave_id,
          'waveletId' => @wavelet_id
        }.to_json
      end

      # *INTERNAL*
      # Delete the blip or, if appropriate, destroy it instead.
      def delete_me(allow_destroy = true) # :nodoc:
        raise "Can't delete root blip" if root?

        if leaf? and allow_destroy
          destroy_me
        else
          # Blip is marked as deleted, but stays in place to maintain structure.
          @state = :deleted
          @content = ''
        end

        @id
      end
      

    protected
      # * INTERNAL *
      # Set the first line of the blips content to title if this is the root blip
      def set_title_text(title)
        if self.root?
          if @content.nil? || @content.empty?  || (lines = @content.split("\n")).length == 1
            #Set the entire content to the title
            @content = title
          else
            #Set the first line of the content to the title
            @content = lines[1..-1].unshift(title).join("\n")
          end
          title
        end
      end
      
      # *INTERNAL*
      # Remove the blip entirely, leaving it null.
      def destroy_me # :nodoc:
        raise "Can't destroy root blip" if root?
        raise "Can't destroy non-leaf blip" unless leaf?

        # Remove the blip entirely to the realm of oblivion.
        parent_blip.remove_child_blip(self)
        @parent_blip_id = nil
        @context.remove_blip(self)
        @state = :null
        @content = ''

        @id
      end
    end
  end
end
