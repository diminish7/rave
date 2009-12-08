# Extend a standard Range so that it can be serialized easily

class Range # :nodoc:
  JAVA_CLASS = 'com.google.wave.api.Range'
  
  # Convert to a hash for sending in an operation.
  def to_json
    {
      'javaClass' => JAVA_CLASS,
      'start' => min,
      'end' => max
    }.to_json
  end
end