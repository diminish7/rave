#Contains server request information including current waves and operations
module Rave
  module Models
    class Context
      attr_reader :waves, :wavelets, :blips, :operations, :users, :primary_wavelet
      
      JAVA_CLASS = 'com.google.wave.api.impl.OperationMessageBundle' # :nodoc:
      
      #Options include:
      # - :waves
      # - :wavelets
      # - :blips
      # - :operations
      # - :users
      # - :robot
      def initialize(options = {})
        @waves = options[:waves] || {}
        @waves.values.each { |wave| wave.context = self }          #Set up self as this wave's context

        @wavelets = options[:wavelets] || {}
        @wavelets.values.each { |wavelet| wavelet.context = self } #Set up self as this wavelet's context
        @primary_wavelet = @wavelets.values[0] # As opposed to any that are created later.
        
        @blips = options[:blips] || {}
        @blips.values.each { |blip| blip.context = self }          #Set up self as this blip's context
        
        @operations = options[:operations] || []
        
        @users = options[:users] || {}
        @users.values.each { |user| user.context = self }          #Set up self as this user's context

        resolve_blip_references
      end

    protected
      # Resolve references to blips that otherwise aren't defined.
      # NOTE: Should only be called during initialisation, since
      # operation-generated blips can't have virtual references.
      def resolve_blip_references # :nodoc:
        @blips.values.each do |blip|
          # Resolve virtual children.
          blip.child_blip_ids.each do |child_id|
            unless child_id.nil?
              child = @blips[child_id]
              if child.nil?
                child = Blip.new(:id => child_id, :parent_blip_id => blip.id,
                  :wavelet_id => blip.wavelet_id)
                add_blip(child)
              else
                # Since a child might have been created due to a reference from
                # one of its real children, we still need to ensure that it knows
                # about us.
                if child.parent_blip_id.nil?
                  child.instance_eval do
                    @parent_blip_id = blip.id # TODO: unhack this!
                  end
                end
              end
            end
          end

          # Resolve virtual parent.
          unless blip.parent_blip_id.nil?
            parent = @blips[blip.parent_blip_id]
            if parent.nil?
              parent = Blip.new(:id => blip.parent_blip_id, :child_blip_ids => [blip.id],
                :wavelet_id => blip.wavelet_id)
              add_blip(parent)
            else
              # Since there might be multiple "real" children, ensure that even
              # if we don't have to create the virtual parent, ensure that
              # it knows about us.
              unless parent.child_blip_ids.include? blip.id
                parent.instance_eval do
                  @child_blip_ids << blip.id # TODO: unhack this!
                end
              end
            end
          end
        end
      end

    public
      # Add a blip to blips (Use an Operation to actually add the blip to the Wave).
      def add_blip(blip) # :nodoc:
        @blips[blip.id] = blip
        blip.context = self
        blip
      end
      
      #Find the root wavelet if it exists in this context
      def root_wavelet
        @wavelets.values.find { |wavelet| wavelet.id =~ Regexp.new(Rave::Models::Wavelet::ROOT_ID_REGEXP) }
      end
           
      #Serialize the context for use in the line protocol.
      def to_json
        hash = {
          'operations' => { 'javaClass' => 'java.util.ArrayList', 'list' => @operations },
          'javaClass' => JAVA_CLASS
        }
        hash.to_json
      end

      def print_structure(indent = 0) # :nodoc:
        str = ''
        waves.each_value do |wave|
          str << wave.print_structure(indent)
        end
        str
      end
    end
  end
end
