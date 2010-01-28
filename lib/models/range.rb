# Extend a standard Range so that it can be serialized easily

class Range # :nodoc:
  JAVA_CLASS = 'com.google.wave.api.Range'
  
  # Convert to a hash for sending in an operation.
  def to_rave_hash
    {
      'javaClass' => JAVA_CLASS,
      'start' => min,
      'end' => max
    }
  end
end